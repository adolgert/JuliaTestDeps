using Test
using JuliaTestDeps


@testset "read_project" begin
    gabs = """
    name = "Gabs"
    uuid = "0eb812ee-a11f-4f5e-b8d4-bb8a44f06f50"
    authors = ["Andrew Kille"]
    version = "1.2.9-dev"
    
    [deps]
    BlockArrays = "8e7c35d0-a365-5155-bbbb-fb81a777f24e"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    QuantumInterface = "5717a53b-5d69-4fa3-b976-0bf2f97ca1e5"
    SymplecticFactorizations = "7425e8e4-4cde-4e45-9b2f-a15679260f9b"
    
    [weakdeps]
    Makie = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    
    [extensions]
    MakieExt = "Makie"
    StaticArraysExt = "StaticArrays"
    
    [compat]
    BlockArrays = "1.1.1"
    LinearAlgebra = "1.9"
    Makie = "0.21, 0.22"
    QuantumInterface = "0.3.8"
    StaticArrays = "1.9.7"
    Symbolics = "6.27.0"
    SymplecticFactorizations = "0.1.5"
    julia = "1.6.7, 1.10.0"
    
    [extras]
    Symbolics = "0c5d862f-8b57-4792-8d23-62f2024744c7"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
    
    [targets]
    test = ["Test", "Makie", "StaticArrays", "Symbolics"]
    """
    name, targets, deps = JuliaTestDeps.read_project(TOML.parse(gabs), false)
    @assert name == "Gabs"
    @assert targets["BlockArrays"] == UUID("8e7c35d0-a365-5155-bbbb-fb81a777f24e")
    @assert deps["test"] == [
        UUID("8dfed614-e22c-5e08-85e1-65c5234f0b40"),
        UUID("ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"),
        UUID("90137ffa-7385-5640-81b9-e52037218182"),
        UUID("0c5d862f-8b57-4792-8d23-62f2024744c7")
    ]
end
