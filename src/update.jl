export update_active_github

function setup_package_subdir(relpath)
    # Get the path to the project directory
    project_dir = project_directory()
    # Create the full path to the subdirectory
    subdir = joinpath(project_dir, relpath)
    # Create the subdirectory if it doesn't exist
    if !isdir(subdir)
        mkpath(subdir)
    end
    return subdir
end


"""
Given the path to a subdirectory in which to store files
and the URL of a Github repository, use the retrieve_github_file
function to download both the Project.toml and the test/Project.toml
and store them in the subdirectory.
"""
function update_single(subdir, filegetter)
    found = String[]
    for fn in ["Project.toml", "test/Project.toml"]
        strfile = getfile(filegetter, fn)
        if strfile !== nothing
            # Create a file in the subdirectory and write the string to that file
            file_path = joinpath(subdir, replace(fn, "/" => "_"))
            open(file_path, "w") do io
                write(io, strfile)
            end
            push!(found, "$fn $(length(strfile))")
        end
    end
    print("Updated $(join(found, ", ")) in $(subdir)\n")
end


function update_if_needed()
    packages = general_project_list()
    could_not_contact=String[]
    for pkg in packages
        println("Working on $(pkg.path) from $(pkg.repo)")
        subdir = setup_package_subdir(pkg.path)
        if isfile(joinpath(subdir, "repo.json"))
            println("Already have repo.json in $(subdir)")
            continue
        end
        try
            repo_info = retrieve_repo(pkg.repo)
            write_to_dir(repo_info, subdir)
            update_single(subdir, repo_info)
        catch err
            if isa(err, RepoUncontactable)
                push!(could_not_contact, pkg.repo)
                println("Cannot contact $(pkg.repo)")
            elseif isa(err, RepoNotGithub)
                push!(could_not_contact, pkg.repo)
                println("Not a Github repo $(pkg.repo)")
            else
                rethrow(err)
            end
        end
        sleep(2)
    end
    println(join(could_not_contact, "\n"))
end


function update_active_github()
    # The Julia/General package repo is the same as the
    # Github clone_url. They are https://github.com....git.
    packages = general_project_list()
    github_repo_dir = github_save_directory()
    for (root, dirs, files) in walkdir(github_repo_dir)
        if "repo.json" in files
            # Get the full path to the JSON file
            json_path = joinpath(root, "repo.json")
            # Read the JSON file
            json_data = JSON3.read(json_path)
            # Extract the clone_url from the JSON data
            clone_url = json_data["clone_url"]
            # Check if the clone_url is in the list of packages
            if !any(pkg -> pkg.repo == clone_url, packages)
                if !isfile(joinpath(root, "Project.toml"))
                    println("Getting tomls for $root")
                    repo_dict = Dict{String,Any}(string(k) => v for (k, v) in json_data)
                    repo_info = GithubRepo(json_data["url"], repo_dict)
                    update_single(root, repo_info)
                else
                    println("Already have toml for $root")
                end
            else
                println("Package $root. Skip.")
            end
            sleep(2)
        end
    end
end
