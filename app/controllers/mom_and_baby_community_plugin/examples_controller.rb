# frozen_string_literal: true

module ::MomAndBabyCommunityPlugin
  class ExamplesController < ::ApplicationController

    def index
      render json: { hello: "world" }
    end
  end
end
