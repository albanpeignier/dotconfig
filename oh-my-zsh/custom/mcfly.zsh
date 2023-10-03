# McFly - fly through your shell history
# https://github.com/cantino/mcfly

# To enable fuzzy searching
export MCFLY_FUZZY=2

# To change the maximum number of results shown (default: 10)
export MCFLY_RESULTS=20

# To change interface view (default: TOP)
export MCFLY_INTERFACE_VIEW=BOTTOM

# To change the sorting of results shown (default: RANK). Possible values RANK and LAST_RUN
export MCFLY_RESULTS_SORT=LAST_RUN

eval "$(mcfly init zsh)"
