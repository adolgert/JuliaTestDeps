using HTTP
using JSON3
using Base64

export search_github_repositories

struct RepoNotGithub <: Exception end

struct GithubRepo
    repourl::String
    properties::Dict{String, Any}
end


function retrieve_repo(repo_url)
    lessgit = replace(repo_url, ".git" => "")
    basic_info = repository_info(lessgit, github_token())
    GithubRepo(lessgit, basic_info)
end


function getfile(getter::GithubRepo, filename::String)
    retrieve_github_file(getter.properties, filename, github_token())
end


function write_to_dir(gr::GithubRepo, subdir)
    open(joinpath(subdir, "repo.json"), "w") do f
        JSON3.write(f, gr.properties)
    end
end


"""
Add headers to make a request from Github API.
"""
function github_api_request(target, token)
    # Set up the headers with the personal access token
    headers = [
        "Authorization" => "token $token",
        "Accept" => "application/vnd.github+json",
        "User-Agent" => "adolgert",
        ]

    # Make the GET request to the GitHub API
    return HTTP.get(target, headers, status_exception=false)
end


function url_owner_name(repo_url)
    # Extract the owner and repo name from the URL
    regm = match(r"https://github\.com/([^/]+)/([^/]+)", repo_url)
    if isnothing(regm)
        throw(RepoNotGithub())
    end

    owner = regm.captures[1]
    repo_name = regm.captures[2]
    return owner, repo_name
end


struct RepoUncontactable <: Exception end


"""
Use the Github API to get information about a repository.
This function accepts a repository URL and a personal access token.
It returns a dictionary with the repository's master branch name.
"""
function repository_info(repo_url, token)
    owner, repo_name = url_owner_name(repo_url)
    # Construct the API URL
    api_url = "https://api.github.com/repos/$owner/$repo_name"

    # Make the GET request to the GitHub API
    response = github_api_request(api_url, token)

    # Check if the request was successful
    if response.status != 200
        throw(RepoUncontactable())
        error("Failed to fetch repository information: $(response.status)")
    end

    # Parse the JSON response
    return JSON3.read(String(response.body))
end


function retrieve_github_file(repo_info, filename, token)

    api_url = replace(repo_info["contents_url"], "{+path}" => filename)
    # Make the GET request to the GitHub API
    response = github_api_request(api_url, token)

    # Check if the request was successful
    if response.status == 200
        data = JSON3.read(String(response.body))
        return String(base64decode(data["content"]))
    else
        return nothing
    end
end


"""
"""
function page_github_repositories(page)
    # Construct the API URL
    api_url = "https://api.github.com/search/repositories?q=language:julia+test&per_page=100&page=$page&sort=created&direction=asc"

    # Make the GET request to the GitHub API
    response = github_api_request(api_url, github_token())

    # Check if the request was successful
    if response.status == 200
        linklines = [last(h) for h in response.headers if first(h) == "Link"]
        more = length(linklines) > 0 && occursin("\"next\"", linklines[1])
        println(linklines)
        data = JSON3.read(String(response.body))
        return more, data
    else
        error("Failed to fetch repository information: $(response.status)")
    end
end


function save_items_to_github_directory(items)
    github_dir = github_save_directory()
    for item in items
        full_name = item["full_name"]
        path = joinpath(github_dir, split(item["full_name"], "/")...)
        if !isdir(path)
            mkpath(path)
        end
        open(joinpath(path, "repo.json"), "w") do f
            JSON3.write(f, item)
        end
    end
end


function search_github_repositories()
    start = 1
    more, data = page_github_repositories(start)
    total_entries = data["total_count"]
    expected_call_cnt = div(total_entries - 1, 100) + 1
    save_items_to_github_directory(data["items"])

    for i in (start + 1):expected_call_cnt
        more, data = page_github_repositories(i)
        save_items_to_github_directory(data["items"])
        if i < expected_call_cnt && !more
            println("last page was $i but $total_entries entries")
        end
        sleep(10)
    end
end
