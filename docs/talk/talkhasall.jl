# The goal is to ensure that the talk in Keynote contains all of the
# Julia packages that are listed in the CSV files, or at least give
# me a list of what is excluded. This is my check that I'm not forgetting
# anybody.

REPACKAGE = r"\w+\.jl"


function search_package_names()
    packages = String[]
    run(`pdftotext JuliaTesting.pdf search.txt`)
    open("search.txt") do io
        whole = read(io, String)
        for mpackage in eachmatch(REPACKAGE, whole)
            push!(packages, mpackage.match)
        end
    end
    sort!(packages)
    return packages
end

for packname in search_package_names()
    println(packname)
end
