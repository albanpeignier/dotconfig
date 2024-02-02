#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Inline version of https://github.com/atreyasha/i3-balance-workspace

from operator import attrgetter
from typing import Iterable, Optional, cast
import argparse
import signal
import re

from typing import List, Dict, Tuple
from argparse import ArgumentParser
import i3ipc

class Timeout:
    """
    Class to create a timeout setting in case resizing gets stuck on
    dead or problematic windows [source: https://stackoverflow.com/a/22348885]
    """
    def __init__(self, seconds, error_message='Process timed out'):
        self.seconds = seconds
        self.error_message = error_message

    def handle_timeout(self, signum, frame):
        raise TimeoutError(self.error_message)

    def __enter__(self):
        signal.signal(signal.SIGALRM, self.handle_timeout)
        signal.alarm(self.seconds)

    def __exit__(self, type, value, traceback):
        signal.alarm(0)

class Sorting_Help_Formatter(argparse.HelpFormatter):
    """ Formatter for sorting argument options alphabetically """

    # source: https://stackoverflow.com/a/12269143
    def add_arguments(self, actions: Iterable[argparse.Action]) -> None:
        actions = sorted(actions, key=attrgetter("option_strings"))
        super(Sorting_Help_Formatter, self).add_arguments(actions)

    def _format_usage(self, usage: str, actions: Iterable[argparse.Action],
                      groups: Iterable[argparse._ArgumentGroup],
                      prefix: Optional[str]) -> str:
        if prefix is None:
            prefix = ("usage: ")

        # if usage is specified, use that
        if usage is not None:
            usage = usage % dict(prog=self._prog)

        # if no optionals or positionals are available, usage is just prog
        elif usage is None and not actions:
            usage = "%(prog)s" % dict(prog=self._prog)

        # if optionals and positionals are available, calculate usage
        elif usage is None:
            prog = "%(prog)s" % dict(prog=self._prog)

            # split optionals from positionals
            optionals = []
            positionals = []

            # split actions temporarily
            help_action = [
                action for action in actions if action.dest == "help"
            ]
            required_actions = sorted(
                [action for action in actions if action.required],
                key=attrgetter("option_strings"))
            optional_actions = sorted([
                action for action in actions
                if not action.required and action.dest != "help"
            ],
                                      key=attrgetter("option_strings"))

            # combine actions back
            actions = help_action + required_actions + optional_actions

            # proceed with usual
            for action in actions:
                if action.option_strings:
                    optionals.append(action)
                else:
                    positionals.append(action)

            # build full usage string
            format = self._format_actions_usage
            action_usage = format(optionals + positionals, groups)
            usage = " ".join([s for s in [prog, action_usage] if s])

            # wrap the usage parts if it's too long
            text_width = self._width - self._current_indent
            if len(prefix) + len(usage) > text_width:

                # break usage into wrappable parts
                part_regexp = (r"\(.*?\)+(?=\s|$)|"
                               r"\[.*?\]+(?=\s|$)|"
                               r"\S+")
                opt_usage = format(optionals, groups)
                pos_usage = format(positionals, groups)
                opt_parts = re.findall(part_regexp, opt_usage)
                pos_parts = re.findall(part_regexp, pos_usage)
                assert " ".join(opt_parts) == opt_usage
                assert " ".join(pos_parts) == pos_usage

                # helper for wrapping lines
                def get_lines(parts, indent, prefix=None):
                    lines = []
                    line = []
                    if prefix is not None:
                        line_len = len(prefix) - 1
                    else:
                        line_len = len(indent) - 1
                    for part in parts:
                        if line_len + 1 + len(part) > text_width and line:
                            lines.append(indent + " ".join(line))
                            line = []
                            line_len = len(indent) - 1
                        line.append(part)
                        line_len += len(part) + 1
                    if line:
                        lines.append(indent + " ".join(line))
                    if prefix is not None:
                        lines[0] = lines[0][len(indent):]
                    return lines

                # if prog is short, follow it with optionals or positionals
                if len(prefix) + len(prog) <= 0.75 * text_width:
                    indent = " " * (len(prefix) + len(prog) + 1)
                    if opt_parts:
                        lines = get_lines([prog] + opt_parts, indent, prefix)
                        lines.extend(get_lines(pos_parts, indent))
                    elif pos_parts:
                        lines = get_lines([prog] + pos_parts, indent, prefix)
                    else:
                        lines = [prog]

                # if prog is long, put it on its own line
                else:
                    indent = " " * len(prefix)
                    parts = opt_parts + pos_parts
                    lines = get_lines(parts, indent)
                    if len(lines) > 1:
                        lines = []
                        lines.extend(get_lines(opt_parts, indent))
                        lines.extend(get_lines(pos_parts, indent))
                    lines = [prog] + lines

                # join lines into usage
                usage = "\n".join(lines)

        # prefix with 'usage:'
        return "%s%s\n\n" % (prefix, usage)


class Metavar_Circum_Symbols(argparse.HelpFormatter):
    """
    Help message formatter which uses the argument 'type' as the default
    metavar value (instead of the argument 'dest')

    Only the name of this class is considered a public API. All the methods
    provided by the class are considered an implementation detail.
    """
    def _get_default_metavar_for_optional(self,
                                          action: argparse.Action) -> str:
        """
        Function to return option metavariable type with circum-symbols
        """
        if action.type is not None:
            return "<" + action.type.__name__ + ">"  # type: ignore
        else:
            action.metavar = cast(str, action.metavar)
            return action.metavar

    def _get_default_metavar_for_positional(self,
                                            action: argparse.Action) -> str:
        """
        Function to return positional metavariable type with circum-symbols
        """
        if action.type is not None:
            return "<" + action.type.__name__ + ">"  # type: ignore
        else:
            action.metavar = cast(str, action.metavar)
            return action.metavar


class Metavar_Indenter(argparse.HelpFormatter):
    """
    Formatter for generating usage messages and argument help strings.

    Only the name of this class is considered a public API. All the methods
    provided by the class are considered an implementation detail.
    """
    def _format_action(self, action: argparse.Action) -> str:
        """
        Function to define how actions are printed in help message
        """
        # determine the required width and the entry label
        help_position = min(self._action_max_length + 2,
                            self._max_help_position + 5)
        help_width = max(self._width - help_position, 11)
        action_width = help_position - self._current_indent - 2
        action_header = self._format_action_invocation(action)

        # no help; start on same line and add a final newline
        if not action.help:
            tup = self._current_indent, "", action_header
            action_header = "%*s%s\n" % tup

        # short action name; start on the same line and pad two spaces
        elif len(action_header) <= action_width:
            tup = self._current_indent, "", action_width, action_header  # type: ignore  # noqa: E501
            action_header = "%*s%-*s  " % tup  # type: ignore
            indent_first = 0

        # long action name; start on the next line
        else:
            tup = self._current_indent, "", action_header
            action_header = "%*s%s\n" % tup
            indent_first = help_position

        # collect the pieces of the action help
        parts = [action_header]

        # if there was help for the action, add lines of help text
        if action.help:
            help_text = self._expand_help(action)
            help_lines = self._split_lines(help_text, help_width)
            if action.nargs != 0 and action.type is not None:
                default = self._get_default_metavar_for_optional(action)
                args_string = self._format_args(action, default)
                parts.append("%*s%s\n" % (indent_first, "", args_string))
            elif action.type is None:
                args_string = "<flag>"
                parts.append("%*s%s\n" % (indent_first, "", args_string))
            else:
                parts.append("%*s%s\n" % (indent_first, "", help_lines[0]))
                help_lines.pop(0)
            for line in help_lines:
                parts.append("%*s%s\n" % (help_position, "", line))

        # or add a newline if the description doesn't end with one
        elif not action_header.endswith("\n"):
            parts.append("\n")

        # if there are any sub-actions, add their help as well
        for subaction in self._iter_indented_subactions(action):
            parts.append(self._format_action(subaction))

        # return a single string
        return self._join_parts(parts)

    def _format_action_invocation(self, action: argparse.Action) -> str:
        """
        Lower function to define how actions are printed in help message
        """
        if not action.option_strings:
            default = self._get_default_metavar_for_positional(action)
            metavar, = self._metavar_formatter(action, default)(1)
            return metavar
        else:
            parts = []  # type: ignore
            parts.extend(action.option_strings)
            return ", ".join(parts)


class ArgparseFormatter(argparse.ArgumentDefaultsHelpFormatter,
                        Metavar_Circum_Symbols, Metavar_Indenter,
                        Sorting_Help_Formatter):
    """
    Class to combine argument parsers in order to display meta-variables
    and defaults for arguments
    """
    pass

def refresh_workspace() -> i3ipc.Con:
    """
    Function refreshes i3 connection and returns the latest workspace container

    Returns:
        workspace (i3ipc.Con): workspace container
    """
    # Retrieve i3 connection
    i3 = i3ipc.Connection()
    # Depending on desired scope, get workspace or focused container
    if SCOPE == "workspace":  # type: ignore
        workspace = i3.get_tree().find_focused().workspace()
    elif SCOPE == "focus":  # type: ignore
        workspace = i3.get_tree().find_focused()
    return workspace


def adjust_container(container: i3ipc.Con, ideal_dim: float,
                     direction: str) -> Tuple[str, i3ipc.CommandReply, float]:
    """
    Function to deterministically adjust a single container

    Args:
        container (i3ipc.Con): i3ipc.Container to adjust
        ideal_dim (float): Target dimension in pixels
        direction (str): Direction in which growing/shrinking should happen

    Returns:
        msg (str): Command sent out to i3
        reply (i3ipc.CommandReply): Reply of resizing command given to i3
        diff (float): Difference metric applied in resizing
    """
    # Retrieve dimensions of provided container
    current_dims = [container.rect.width, container.rect.height]
    # Adjust containers by either resizing rightwards or downwards
    # since i3 tree layout provides containers from left to right
    # and consequently from upwards to downwards
    if direction == "width":
        # If width is to be adjusted, compute difference and adjust
        diff = ideal_dim - current_dims[0]
        if diff >= 0:
            msg = "resize grow right %d px" % diff
        else:
            msg = "resize shrink right %d px" % abs(diff)
    elif direction == "height":
        # If height is to be adjusted, compute difference and adjust
        diff = ideal_dim - current_dims[1]
        if diff >= 0:
            msg = "resize grow down %d px" % diff
        else:
            msg = "resize shrink down %d px" % abs(diff)
    # Capture the reply of the command to check success
    reply = container.command(msg)
    # Return both reply and the actual message, in case an error occurs
    return msg, reply, diff


def recursive_adjustment(containers: List[i3ipc.Con], ids: List[int],
                         dim: str) -> List[i3ipc.Con]:
    """
    Function to recursively adjust list of containers at a given tree level

    Args:
        containers (List[i3ipc.Con]): List of containers to recursively adjust
        ids (List[int]): List of id's of respective containers
        dim (str): Which dimension to address during adjustment

    Returns:
        containers (List[i3ipc.Con]): Update list of containers for other
        processes to refer back to
    """
    redo = True
    counter = 0
    # Based on the number of containers, compute the ideal balanced dimension
    ideal_dim = (
        sum([getattr(container.rect, dim)
             for container in containers]) / len(containers))
    # Errors can occur when expanding one container so much that another
    # container loses too much of its own size. In order to deal with such
    # cases we need to adjust the containers recursively until the ideal
    # dimension differences smooth out and the errors stop
    while redo and counter < (len(containers) - 1):
        redo = False
        # Loop through i3 tree left-to-right and top-to-bottom.
        # We only need to adjust the first N-1 containers since
        # the last container will be automatically adjusted to fill
        # up the remaining gaps
        for i in range(len(containers) - 1):
            # Compute the initial percentage to ensure successful adjustment
            # is indeed meaningful and not an illusion
            initial_sample_percentage = containers[i].percent
            # Adjust the container and retrieve message/reply
            msg, reply, diff = adjust_container(containers[i], ideal_dim, dim)
            # Refresh the workspace and containers to get updated data
            workspace = refresh_workspace()
            containers = [workspace.find_by_id(ID) for ID in ids]
            # Check for errors and decide how to handle them
            if reply[0].error is not None:
                if reply[0].error == "Cannot resize.":
                    # This error means the current container is encroaching too
                    # much into the adjacent container and therefore the resize
                    # operation is being blocked. The only option is to
                    # continue resizing the next containers and redo the
                    # resize operation on this container
                    redo = True
                elif reply[
                        0].error == "No second container found in this direction.":
                    # Due to possible errors with gaps, containers are adjusted
                    # in meaningless directions, which should be stopped
                    redo = False
                    break
            elif reply[0].success and initial_sample_percentage == containers[
                    i].percent and int(diff) != 0:
                # Although sucessful, the container's percentage didn't change.
                # This error arises mainly in i3-gaps where a container is
                # erroneously adjusted in a direction where it would not need
                # to be adjusted without gaps. Essentially gaps contribute to
                # some misleading dimensions which cause this problem.
                # This segment tries to undo adjustment when this error happens
                # and then attempts to exit this entire recursive loop
                redo = False
                # Here we reverse the wrong adjustment message
                if "grow" in msg:
                    opp_msg = msg.replace("grow", "shrink")
                elif "shrink" in msg:
                    opp_msg = msg.replace("shrink", "grow")
                # Execute the reverse message
                containers[i].command(opp_msg)
                # Return the new containers and their states
                workspace = refresh_workspace()
                containers = [workspace.find_by_id(ID) for ID in ids]
                # Break for-loop and consequently gracefully exit while-loop
                break
        counter += 1
    return containers


def balance_containers(containers: List[i3ipc.Con]) -> None:
    """
    Function to balance list of containers

    Args:
        containers (List[i3ipc.Con]): List of containers to recursively adjust
    """
    # Capture the ids of the relevant containers to re-use later
    ids = [container.id for container in containers]
    # Check if all containers have the same heights and widths.
    # If either heights or widths differ, create a boolean to adjust them.
    # Ideally (on i3 without gaps), only either adjust_heights or adjust_widths
    # should be 'True'. However, on i3-gaps both can be 'True' beacuse of
    # issues related to dimension computation with the presence of gaps.
    # We deal with this edge case in i3-gaps by adding an error catcher in
    # `recursive_adjustment`
    adjust_heights = not all(container.rect.height == containers[0].rect.height
                             for container in containers)
    adjust_widths = not all(container.rect.width == containers[0].rect.width
                            for container in containers)
    if adjust_widths:
        containers = recursive_adjustment(containers, ids, "width")
    if adjust_heights:
        containers = recursive_adjustment(containers, ids, "height")


def traverse_workspace(
        workspace: i3ipc.Con) -> Dict[int, List[List[i3ipc.Con]]]:
    """
    Function to traverse and parse the workspace tree by level

    Args:
        workspace (i3ipc.Con): Workspace container

    Returns:
        level_nodes (Dict[int, List[List[i3ipc.Con]]]): Dictionary mapping of
        workspace tree
    """
    node_collection = workspace.nodes
    level_nodes = {0: [node_collection]}
    i = 1
    # Here, we simply expand the workspace tree until we hit the terminal
    # nodes. Along the way, we store all nodes at each level of the tree
    while True:
        node_collection = [
            node.nodes for node_list in level_nodes[i - 1]
            for node in node_list if len(node.nodes) > 0
        ]
        if len(node_collection) > 0:
            # This is to ensure no empty lists are appended, otherwise break
            level_nodes[i] = node_collection
            if any(
                    len(node.nodes) > 0 for node_list in level_nodes[i]
                    for node in node_list):
                # If any nodes appended have child nodes, keep expanding.
                # If not, break this while-loop
                i += 1
            else:
                break
        else:
            break
    return level_nodes


def main() -> None:
    """
    Main function to balance i3 window sizes with timeout as failsafe
    in case of problematic recursions or stale windows
    """
    # Parse arguments
    parser = ArgumentParser(formatter_class=ArgparseFormatter)
    parser.add_argument("--scope",
                        type=str,
                        default="workspace",
                        choices=["workspace", "focus"],
                        help="scope of resizing containers")
    parser.add_argument("--timeout",
                        type=int,
                        default=1,
                        help="timeout in seconds for resizing")
    args = parser.parse_args()
    # Create a global SCOPE variable which will be re-used by
    # the `refresh_workspace` function. Global variable is used
    # here to mitigate passing this variable to many functions
    # repeatedly
    global SCOPE
    SCOPE = args.scope  # type: ignore
    # Generate workspace and tree
    workspace = refresh_workspace()
    workspace_tree = traverse_workspace(workspace)
    # Add a timer here to prevent any edge-case problematic recursions
    with Timeout(seconds=args.timeout):
        for i in sorted(workspace_tree.keys(), reverse=True):
            # Start processing workspace tree bottom-up
            for j in range(len(workspace_tree[i])):
                # Go through lists of containers one-by-one
                containers = workspace_tree[i][j]
                # In rare cases where a user mistakenly makes one container
                # too small, this container encounters an error and appears to
                # have a width or height dimension that exceeds that of the
                # workspace it inhabits. This is a logical error and such
                # containers are simply filtered out and ignored
                containers = [
                    container for container in containers
                    if container.rect.width <= workspace.rect.width
                    and container.rect.height <= workspace.rect.height
                ]
                if len(containers) > 1:
                    # Only proceed with balancing if there are more than one
                    # meainingful containers to actually balance
                    balance_containers(containers)
                    # Refresh the workspace and workspace tree
                    # so that this variable can be re-used dynamically
                    # in this for-loop
                    workspace = refresh_workspace()
                    workspace_tree = traverse_workspace(workspace)

if __name__ == "__main__":
    main()
