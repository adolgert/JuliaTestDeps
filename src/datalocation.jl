using TOML

using Memoize


@memoize function github_token()
    patfile = joinpath(data_directory(), "github_pat.txt")
    envtoken = get(ENV, "GITHUBTOKEN", nothing)
    if envtoken !== nothing
        return strip(envtoken)
    elseif isfile(patfile)
        return strip(read(patfile, String))
    else
        error("GitHub personal access token file not found")
    end
end


@memoize function data_directory()
    if isdir("data")
        return "data"
    elseif isdir(normpath("../data"))
        return normpath("../data")
    else
        error("Cannot find data directory")
    end
end


@memoize function project_directory()
    project_dir = joinpath(data_directory(), "project")
    if !isdir(project_dir)
        mkdir(project_dir)
    end
    return project_dir
end


@memoize function github_save_directory()
    general_dir = joinpath(data_directory(), "github")
    if !isdir(general_dir)
        mkdir(general_dir)
    end
    return general_dir
end


struct GeneralPackage
    path::String
    repo::String
end


function general_project_list()
    general_base = expanduser("~/dev/General")

    packages = GeneralPackage[]
    for (root, dirs, files) in walkdir(general_base)
        if "Package.toml" in files
            path = joinpath(root, "Package.toml")
            repo = TOML.parse(String(read(open(path))))["repo"]
            pack_path = relpath(root, general_base)
            push!(packages, GeneralPackage(pack_path, repo))
        end
    end
    return packages
end
