class DependencyTree

    constructor:(@root)->

    ###
        Retrurns a list of dependency nodes where for each node in the list
        if i < j then either nodes[i] does not require node[j], the converse is not guaranteed
        therefore the resulting list has the dependency order solved.
        In the following example tree
             a
            / \
           b   c
          /   / \
         d   e   f

        the dependencies are d > b > a, e > c > a and f > c > a
        therefore a possible result is
        [ a, b, c, d, e, f ]
        Note that this is equivalent of doing a BFS over the tree.

    ###
    getResolvedDependencies:()->
        resolvedDependencies = []
        nodes = []
        while nodes.length > 0

            node = nodes.pop()
            resolvedDependencies.push(node)
            for child in node.children
                nodes.push(child)

        return resolvedDependencies

# TODO
class DependencyNode

    constructor:(@path, @children=[])


