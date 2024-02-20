using GlobalBrain
using Test

@testset "GlobalBrain.jl" begin
    # add tests here
    @test true
end

@testset "Binary entropy" begin
    # surprisal
    @test_throws AssertionError surprisal(0.0)
    @test surprisal(0.25) == 2.0
    @test surprisal(0.5) == 1.0
    @test surprisal(0.75) ≈ 0.41 atol = 0.01
    @test surprisal(1.0) == 0.0
    @test_throws AssertionError surprisal(2.0)
    @test_throws AssertionError surprisal(0.0, 3)
    @test surprisal(0.25, 3) ≈ 1.26 atol = 0.01

    # entropy
    @test_throws AssertionError entropy(0.0)
    @test entropy(0.25) ≈ 0.81 atol = 0.01
    @test entropy(0.5) == 1.0
    @test entropy(0.75) ≈ 0.81 atol = 0.01
    @test entropy(1.0) == 0.0

    # cross_entropy
    @test_throws AssertionError cross_entropy(0.0, 0.0)
    @test cross_entropy(0.0, 0.1) ≈ 0.15 atol = 0.01
    @test_throws AssertionError cross_entropy(0.0, 1.0)
    @test_throws AssertionError cross_entropy(-0.1, 0.5)
    @test_throws AssertionError cross_entropy(1.1, 0.5)
    @test cross_entropy(0.25, 0.5) == 1.0
    @test cross_entropy(1.0, 0.1) ≈ 3.32 atol = 0.01

    # relative_entropy
    @test_throws AssertionError relative_entropy(1.1, 0.5)
    @test_throws AssertionError relative_entropy(0.5, 1.1)
    @test_throws AssertionError relative_entropy(0.0, 0.5)
    @test_throws AssertionError relative_entropy(0.5, 0.0)
    @test_throws AssertionError relative_entropy(0.5, 1.0)
    @test relative_entropy(0.5, 0.5) == 0.0
    @test relative_entropy(0.25, 0.25) == 0.0
    @test relative_entropy(0.25, 0.75) ≈ 0.79 atol = 0.01
    @test relative_entropy(0.1, 0.9) ≈ 2.53 atol = 0.01

    # information_gain
    @test information_gain(0.3, 0.5, 0.5) == 0.0
    @test information_gain(0.1, 0.75, 0.75) == 0.0
    @test information_gain(0.5, 0.25, 0.75) ≈ 0.0 atol = 0.000001
        # TODO: Is this expected behavior?
    @test information_gain(0.5, 0.2, 0.1) < 0.0
    @test information_gain(0.5, 0.2, 0.3) > 0.0
    @test information_gain(0.43, 0.79, 0.55) ≈ 0.40 atol = 0.01
    @test_throws AssertionError information_gain(0.5, 0.1, 0.0)
    @test_throws AssertionError information_gain(0.5, 0.9, 1.0)
    @test_throws AssertionError information_gain(0.5, 0.0, 0.1)
    @test_throws AssertionError information_gain(0.5, 1.0, 0.9)
    @test_throws AssertionError information_gain(1.1, 0.8, 0.9)
    @test_throws AssertionError information_gain(-0.1, 0.5, 0.4)
end


