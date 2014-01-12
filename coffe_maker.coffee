###

    Given a directory as input, the following will attempt to read every file in the
    tree and search for the following lines:

    # an optional @ignore line indicating that this file should not be considered
    @ignore

    # a list of require statements indicating that this file requires the following file
    # note that the <space> is required between the @require and the <path>
    @require <path>
    @require <path>
    ...
    @require <path>

###

fs = require 'fs'

class CoffeeMaker

    constructor:(@dir, @extension='coffee')->
        @validFileNames = []

    getResolvedDependencies:()->

        dependencyList = []

        validFileNames = @getValidFileNames()
        for fileName in validFileNames

            fileParser = new FileParser(fileName)
            if !fileParser.ignore()
                dependencies = fileParser.getDependencies()
                dependencyList.push(dependencies)

        console.log dependencyList
        #dependencyTree = new DependencyTree(dependencyList)
        return dependencyTree.getResolvedDependencies()

    ###

        @return {array of string} returns an array containing all valid
        files ending with the extension @extension
    ###
    getValidFileNames:()->
        @getFiles(@dir)
        return @validFileNames


    getFiles:(dir)->
        files = fs.readdirSync(dir)

        for file in files
            name = dir+'/'+file

            if fs.statSync(name).isDirectory()
                @getFiles(name)
            else if @matchesExtension(name)

                @validFileNames.push(name)



    ###
        @return {boolean} returns true if the file matches the extension
    ###
    matchesExtension:(file)->
        lastIndex = file.lastIndexOf(@extension)
        return (lastIndex != -1) && (lastIndex + @extension.length == file.length)




class FileParser

    constructor:(@fileName)->
        @dependencies = []

        contents = fs.readFileSync(@fileName,'utf8')
        lines = contents.split('\n')
        for line in lines
            if /# require .*/.test(line)
                file = line.split(' require ')[1]
                file = file.trim()
                @dependencies.push(file)

    ignore:()->
        return false

    #
    # @return {object} returns an object with the following structure
    # {
    #   path: <a valid file path>,
    #   dependencies: [ <a list of valid file paths> ]
    # }
    #
    getDependencies:()->
        return {
            path: @fileName,
            dependencies: @dependencies
        }


console.log "starting CoffeeMaker"
coffeeMaker = new CoffeeMaker('./test')
coffeeMaker.getResolvedDependencies()