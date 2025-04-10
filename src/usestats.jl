# Get usage statistics by looking at the Project.toml files.
using CSV
using DataFrames
using TOML
using UUIDs

export read_all_package_targets, most_used_in_test, who_uses

function read_project(project_dict, is_test)
    target_dict = Dict{String,UUID}()
    dependency = Dict{String,Vector{UUID}}()

    if haskey(project_dict, "name") && haskey(project_dict, "uuid")
        project_name = project_dict["name"]
        target_dict[project_name] = UUID(project_dict["uuid"])
    else
        project_name = nothing
    end

    for section in ["deps", "weakdeps", "extras"]
        if haskey(project_dict, section)
            for (pkg, uuid_str) in project_dict[section]
                target_dict[pkg] = UUID(uuid_str)
            end
        end
    end
    if haskey(project_dict, "targets")
        for (target, target_deps) in project_dict["targets"]
            dependency[target] = [
                target_dict[pkg] for pkg in target_deps if haskey(target_dict, pkg)
                ]
        end
    end
    if haskey(project_dict, "deps")
        default_target = Dict(false => "main", true => "test")
        dependency[default_target[is_test]] = [
            target_dict[pkg] for pkg in keys(project_dict["deps"]) if haskey(target_dict, pkg)
            ]
    end
    return project_name, target_dict, dependency
end

struct NoPackageException <: Exception end


function read_package_targets(package_dir)
    target_dict = Dict{String,UUID}()
    dependency = Dict{String,Vector{UUID}}()

    project_names = Union{String,Nothing}[]
    for fn in ["Project.toml", "test_Project.toml"]
        path_fn = joinpath(package_dir, fn)
        if isfile(path_fn)
            project_dict = nothing
            try
                project_dict = TOML.parse(read(open(path_fn), String))
            catch err
                if isa(err, TOML.ParserError)
                    println("Error parsing $(path_fn): $(err)")
                    continue
                else
                    rethrow(err)
                end
            end
            name, one_target, one_deps = read_project(project_dict, startswith(fn, "test"))
            push!(project_names, name)
            # update the target_dict with one_target
            merge!(target_dict, one_target)
            for (dep_path, deps) in one_deps
                if haskey(dependency, dep_path)
                    dependency[dep_path] = union(dependency[dep_path], deps)
                else
                    dependency[dep_path] = deps
                end
            end
        end
    end
    try
        project_name = something(project_names...)
        uuid_dict = Dict(value => key for (key, value) in target_dict)
        return project_name, uuid_dict, dependency
    catch err
        if isa(err, ArgumentError)
            throw(NoPackageException())
        else
            rethrow(err)
        end
    end
end


function read_all_package_targets()
    packages = Dict{UUID,String}()
    dependencies = Dict{String,Dict{String,Vector{UUID}}}()

    for (root, dirs, files) in walkdir(project_directory())
        if "Project.toml" in files
            try
                project_name, uuid_dict, dependency = read_package_targets(root)
                merge!(packages, uuid_dict)
                dependencies[project_name] = dependency
            catch err
                if isa(err, NoPackageException)
                    println("No package found in $(root)")
                else
                    rethrow(err)
                end
            end
        end
    end
    return packages, dependencies
end


function most_used_in_test(packages, dependencies)
    usage_count = Dict{UUID,Int}()
    for (pkg, deps) in dependencies
        if haskey(deps, "test")
            for dep in deps["test"]
                if haskey(packages, dep)
                    usage_count[dep] = get(usage_count, dep, 0) + 1
                end
            end
        end
    end
    # Sort the usage count in descending order
    sorted_usage = sort(collect(usage_count), by = last, rev = true)
    byname = [
        (packages[uuid], count) for (uuid, count) in sorted_usage
        if haskey(packages, uuid)
    ]
    return DataFrame(byname)
end


function who_uses(packages, dependencies, pkg_name)
    pkg_uuid = nothing
    for (uuid, name) in packages
        if name == pkg_name
            pkg_uuid = uuid
            break
        end
    end
    @assert !isnothing(pkg_uuid) "Package $(pkg_name) not found in the list of packages."

    foundin = String[]
    for (pkg, deps) in dependencies
        if haskey(deps, "test")
            for auuid in deps["test"]
                if auuid == pkg_uuid
                    push!(foundin, pkg)
                end
            end
        end
    end
    return foundin
end
