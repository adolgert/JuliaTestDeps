using Test
using JuliaTestDeps


@testset "Writing a Toml" begin
    struct FileGetter
    end
    JuliaTestDeps.project_directory() = "test/project"
    JuliaTestDeps.getfile(fg::FileGetter, fn) = "Test file"

    JuliaTestDeps.update_single("A/Aardvark", FileGetter())
end

@testset "Access List" begin
    @assert length(JuliaTestDeps.general_project_list()) > 100
end
