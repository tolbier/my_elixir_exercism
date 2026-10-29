# Pythagorean Triplet

Welcome to Pythagorean Triplet on Exercism's Elixir Track.
If you need help running the tests or submitting your code, check out `HELP.md`.
If you get stuck on the exercise, check out `HINTS.md`, but try and solve it without using those first :)

## Introduction

You are an accomplished problem-solver, known for your ability to tackle the most challenging mathematical puzzles.
One evening, you receive an urgent letter from an inventor called the Triangle Tinkerer, who is working on a groundbreaking new project.
The letter reads:

> Dear Mathematician,
>
> I need your help.
> I am designing a device that relies on the unique properties of Pythagorean triplets — sets of three integers that satisfy the equation a² + b² = c².
> This device will revolutionize navigation, but for it to work, I must program it with every possible triplet where the sum of a, b, and c equals a specific number, N.
> Calculating these triplets by hand would take me years, but I hear you are more than up to the task.
>
> Time is of the essence.
> The future of my invention — and perhaps even the future of mathematical innovation — rests on your ability to solve this problem.

Motivated by the importance of the task, you set out to find all Pythagorean triplets that satisfy the condition.
Your work could have far-reaching implications, unlocking new possibilities in science and engineering.
Can you rise to the challenge and make history?

## Instructions

A Pythagorean triplet is a set of three natural numbers, {a, b, c}, for which,

```text
a² + b² = c²
```

and such that,

```text
a < b < c
```

For example,

```text
3² + 4² = 5².
```

Given an input integer N, find all Pythagorean triplets for which `a + b + c = N`.

For example, with N = 1000, there is exactly one Pythagorean triplet for which `a + b + c = 1000`: `{200, 375, 425}`.

## Slow tests

One or several of the tests of this exercise have been tagged as `:slow`, because they might take a long time to finish. For this reason, they will not be run on the platform by the automated test runner. If you are solving this exercise directly on the platform in the web editor, you might want to consider downloading this exercise to your machine instead. This will allow you to run all the tests and check the efficiency of your solution.

## Source

### Created by

- @petehuang

### Contributed to by

- @andrewsardone
- @angelikatyborska
- @Cohen-Carlisle
- @dalexj
- @devonestes
- @jiegillet
- @jinyeow
- @lpil
- @neenjaw
- @parkerl
- @rubysolo
- @sotojuan
- @Teapane
- @waiting-for-dev

### Based on

A variation of Problem 9 from Project Euler - https://projecteuler.net/problem=9