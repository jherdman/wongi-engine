module Wongi::Engine

  class BetaMemory < BetaNode
    attr_reader :tokens

    def initialize parent
      super
      @tokens = []
    end

    def seed assignments = {}
      @seed = assignments
      t = Token.new( nil, nil, assignments )
      t.node = self
      @tokens << t
    end

    def subst valuations
      @tokens.first.delete

      token = Token.new( nil, nil, @seed )
      token.node = self
      @tokens << token

      valuations.each { |variable, value| token.subst variable, value }
      self.children.each do |child|
        child.beta_activate token
      end
    end

    def beta_activate token, wme, assignments
      dp "MEMORY beta-activated with #{wme} #{wme.object_id}"
      t = Token.new( token, wme, assignments)
      t.node = self
      existing = @tokens.find { |et| et.duplicate? t }
      if existing
        t = existing
      else
        dp "generated token #{t}"
        t.node = self
        @tokens << t
      end
      self.children.each do |child|
        if child.kind_of? BetaMemory
          child.beta_activate t, nil, {}
        else
          child.beta_activate t
        end
      end
    end

    def refresh_child child
      tokens.each do |token|
        case child
        when BetaMemory, NegNode
          child.beta_activate token, nil, {}
        else
          child.beta_activate token
        end
      end
    end

    def delete_token token
      tokens.delete token
    end

    # => TODO: investigate if we really need this
    #def beta_memory
    #  self
    #end

  end

end
