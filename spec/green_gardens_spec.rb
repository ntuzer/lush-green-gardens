require 'green_gardens'
require 'rspec'

describe LushGreenGardens do
  let(:garden) { LushGreenGardens.new("REWEL") }
  let(:R) do
    [
      2,3,3,3,3,3,0,
      2,3,2,3,2,2,0,
      2,3,3,2,3,3,0,
      2,2,2,2,2,2,0
    ]
  end
  let(:E) do
    [
      2,3,3,3,3,3,0,
      2,3,2,3,2,3,0,
      2,3,2,2,2,3,0,
      2,2,2,2,2,2,0
    ]
  end

  describe "#initialize" do
    it "should load the first letter" do
      expect(garden.current_letter).to eq(R)
    end
  end

  describe "#next_letter" do
    it "should return the next letter" do
      expect(garden.next_letter()).to eq(E)
    end
  end

  describe "#num_of_commits" do
    it "should remove numbers from front of array" do
      garden.num_of_commits()
      expect(garden.current_letter).to eq(R[1..-1])
    end


    it "should load the next letter if finished with current" do
      29.times { garden.num_of_commits() }
      expect(garden.current_letter).to eq(E[1..-1])
    end

    it "should return a random number in range" do
      #first number in R is 2, so the range is 5-10
      rand_num = garden.num_of_commits()
      expect(rand_num).to be <=10
      expect(rand_num).to be >=5
    end



  end


end
