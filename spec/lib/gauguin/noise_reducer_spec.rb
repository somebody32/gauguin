require 'spec_helper'

module Gauguin
  describe NoiseReducer do
    let(:reducer) { NoiseReducer.new }

    describe "#reduce" do
      subject { reducer.call(colors).keys }

      let(:white) { Color.new(255, 255, 255) }
      let(:red) { Color.new(255, 0, 0) }
      let(:black) { Color.new(0, 0, 0) }

      let(:colors) do
        [
          [black, 0.97],
          [red, 0.02],
          [white, 0.01]
        ]
      end

      configure(:min_percentage_sum, 0.96)

      it "returns only relevant colors" do
        expect(subject).to eq([black])
      end

      context "no sum greater than min_percentage_sum" do
        let(:colors) do
          [
            [black, 0.9],
            [red, 0.01],
            [white, 0.02]
          ]
        end

        it "returns all colors" do
          expect(subject).to eq([black, red, white])
        end
      end

      context "transparent color" do
        configure(:min_percentage_sum, 0.98)

        before do
          white.transparent = true
        end

        it "returns all colors except white" do
          expect(subject).to eq([black, red])
        end
      end
    end
  end
end
