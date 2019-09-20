require 'benchmark'
require 'bundler/inline'

gemfile do
  source "https://rubygems.org"
  gem 'tty-progressbar'
  gem "benchmark-memory"
  gem "colsole"
end

class BM
  include Colsole

  attr_reader :loops

  def add(label=:global, &block)
    tests[label] = block
  end

  def run(loops = 10)
    memory
    time loops
  end

  def memory
    say "!txtgrn!Starting memory benchmark"

    Benchmark.memory do |x|
      tests.each do |label, block|
        x.report label, &block
      end

      x.compare!
    end
    puts
  end

  def time(loops=10)
    @loops = loops
    say "!txtgrn!Starting execution time benchmark (#{loops} loops)"
    bar = TTY::ProgressBar.new "Running [:bar]", total: loops * tests.size

    loops.times do |i|
      tests.each do |label, block|
        measure i, label, &block
        bar.advance
      end
    end

    report
  end

private

  def measure(i, label, &block)
    time = Benchmark.measure do
      block.call i
    end

    time = time.real
    
    results[label] ||= {}
    results[label][:total] ||= 0
    results[label][:total] += time
    results[label][:average] = results[label][:total] / loops
    results[label][:throughput] = loops / results[label][:total]
  end

  def report
    sorted_results = results.sort_by { |k, v| v[:total] }
    puts "%35s %16s" % ["average", "throughput"]
    sorted_results.each do |label, stats|
      puts "%20s %10.3f sec %12.2f cps"  % [
        label, 
        stats[:average],
        stats[:throughput],
      ]
    end
    puts
  end

  def results
    @results ||= {}
  end

  def tests
    @tests ||= {}
  end

end
