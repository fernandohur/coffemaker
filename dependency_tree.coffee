class DependencyTree



    ###

        Given a list of dependencies like the following:

        [
            { path: './test/A.coffee', dependencies: [ 'B.coffee' ] },
            { path: './test/B.coffee', dependencies: [ 'C.coffee', 'D.coffee' ] },
            { path: './test/C.coffee', dependencies: [] },
            { path: './test/D.coffee', dependencies: [] }
        ]

        It will construct a tree of dependencies

    ###
    constructor:(@rootDir, deps)->
        console.log "Creating DependencyTree from root #{@rootDir}"
        console.log "Dependency list"
        cleanDeps = @cleanDependencyList(deps)
        @roots = @createTree(cleanDeps) # note that there can be more than one root (independent trees)

    cleanDependencyList:(deps)->
        for dep in deps
            dep.path = dep.path.replace(@rootDir+"/","")
        return deps

    createTree:(deps)->
        # this maps <file name> => DependencyNode
        pathHash = {}
        nodes = []
        for dep in deps
            pathHash[dep.path] = new DependencyNode(dep.path)
        for dep in deps
            node = pathHash[dep.path]
            for dependency in dep.dependencies
                child = pathHash[dependency]
                node.addDependency(child)
            nodes.push node

        result = []
        for node in nodes
            result.push node if node.isRoot()

        @printTrees(result)
        return result

    printTrees:(rootList)->
        for node in rootList
            @levelIteration node, (node, level)->
                space = ""
                while level > 0
                    space += "\t"
                    level--
                console.log "#{space} {#{node.path}}"

    bfs:(node, callback)->
        queue = [node]
        while queue.length > 0
            node = queue.shift()
            callback(node)
            queue.push(dep) for dep in node.dependencies

    # callback = function(DependencyNode, currentLevel)
    levelIteration:(node, callback)->
        node.levelIteration(0, callback)

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
        Note that this is (more or less) equivalent of doing a BFS over the tree.

    ###
    getResolvedDependencies:()->
        result = []
        for root in @roots
            @bfs root, (node)->
                index = result.indexOf(node.path)
                result.splice(index,1) if index != -1
                result.push node.path

        return result

# TODO
class DependencyNode

    constructor:(@path)->
        @dependencies = []
        @parents = []

    addDependency:(node)->
        @dependencies.push node
        node.parents.push this

    getDependencyPaths:()->
        result = []
        for node in @dependencies
            result.push node.path
        return result

    getParentPaths:()->
        result = []
        for node in @parents
            result.push node.path
        return result

    isRoot:()->
        return @parents.length == 0

    # callback = function(DependencyNode, currentLevel)
    levelIteration:(currentLevel, callback)->
        callback(this, currentLevel)
        for dep in @dependencies
            dep.levelIteration(currentLevel+1, callback)

module.exports = {

    DependencyTree: DependencyTree
}


