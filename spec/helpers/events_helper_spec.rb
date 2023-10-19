# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventsHelper do
  describe "#date_range" do
    subject { date_range(event) }

    let(:event) { create :event, start_at: "2021-11-08 00:00:00", end_at: "2021-11-10 00:00:00" }

    it { is_expected.to eq "November 08, 2021 - November 10, 2021" }

    context "when 1 day event" do
      let(:event) { create :event, :one_day }

      it { is_expected.to eq "August 05, 2021 21:00 - 23:59" }
    end
  end
end
