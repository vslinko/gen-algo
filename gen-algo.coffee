random = (min = 0, max = 100000000000000000) ->
  Math.round(Math.random() * (max - min)) + min


class Population
  constructor: (@individuals, @crossover, @mutation, @fitness) ->
    @_sort()

  nextGeneration: ->
    @_crossover()
    @_mutation()
    @_selection()
    @

  bestIndividual: ->
    @individuals[0]

  _crossover: ->
    @individuals.sort ->
      random(0, 2) - 1

    length = @individuals.length
    for i in [0...length-1] by 2
      a = @individuals[i]
      b = @individuals[i + 1]
      childs = @crossover.crossover a, b
      @individuals = @individuals.concat childs

  _mutation: ->
    @mutation.mutation @individuals

  _selection: ->
    @_sort()

  _sort: ->
    @individuals.sort (a, b) =>
      @fitness.fitness(b) - @fitness.fitness(a)


class LimitedPopulation extends Population
  constructor: ->
    super
    @initialLength = @individuals.length

  _selection: ->
    super
    @individuals.splice @initialLength


class OnePointCrossover
  constructor: (@Individual) ->

  crossover: (a, b) ->
    length = Math.min a.chromosomes.length, b.chromosomes.length
    point = random(0, length - 1)

    a1 = a.chromosomes.slice(0, point)
    a2 = a.chromosomes.slice(point, length)
    b1 = b.chromosomes.slice(0, point)
    b2 = b.chromosomes.slice(point, length)
    c1 = a1.concat(b2)
    c2 = b1.concat(a2)

    [@Individual.factory(c1), @Individual.factory(c2)]


class OnePercentRandomGeneMutation
  constructor: (@Individual) ->

  mutation: (individuals) ->
    for individual in individuals
      if random(0, 100) == 0
        i = random(0, individual.chromosomes.length - 1)
        individual.chromosomes[i] = @Individual.randomChromosome()


class ChromosomesSumFitness
  fitness: (individual) ->
    chromosomes = individual.chromosomes
    fitness = 0
    fitness += chromosomes[i] for i in [0...chromosomes.length]
    fitness


class DNAFitness
  fitness: (individual) ->
    dna = individual.chromosomes.join ""
    rna = dna.replace /T/g, "U"

    started = false
    fitness = 0

    for i in [0...rna.length-2] by 3
      codon = rna[i] + rna[i + 1] + rna[i + 2]

      if codon is "AUG"
        started = true
        continue

      if codon in ["UAA", "UAG", "UGA"]
        break

      if started
        fitness += 1

    fitness


class Individual
  @chromosomes = (i for i in [1..100])

  @randomChromosome = ->
    @chromosomes[random(0, @chromosomes.length - 1)]

  @random = (length) ->
    @factory (@randomChromosome() for i in [0...length])

  @factory = (chromosomes) ->
    individual = new @
    individual.chromosomes = chromosomes
    individual


class DNAIndividual
  @chromosomes = ["G", "A", "T", "C"]
  @random = Individual.random
  @randomChromosome = Individual.randomChromosome
  @factory = Individual.factory


initialization = ->
  chromosomesLength = 240
  length = 10

  individuals = (DNAIndividual.random(chromosomesLength) for i in [0...length])
  crossover = new OnePointCrossover DNAIndividual
  mutation = new OnePercentRandomGeneMutation DNAIndividual
  fitness = new DNAFitness
  new LimitedPopulation individuals, crossover, mutation, fitness


termination = (generation, population) ->
  bestIndividual = population.bestIndividual()
  fitness = population.fitness.fitness bestIndividual
  generation == 100000 or fitness == 78


log = (generation, population, last) ->
  bestIndividual = population.bestIndividual()
  fitness = population.fitness.fitness bestIndividual

  if generation % 100 == 0
    console.log generation, fitness, bestIndividual.chromosomes.join ""

  if last
    console.log "\nlast:"
    console.log generation, fitness, bestIndividual.chromosomes.join ""


do main = ->
  population = initialization()
  generation = 0
  while true
    population.nextGeneration()
    generation += 1
    last = termination generation, population
    log generation, population, last
    break if last
