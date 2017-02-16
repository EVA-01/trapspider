module Recluse
  ##
  # Sorta like a node tree but using two hashes for easy searching for parents and/or children.
  # This way, it should have similar performance whether you're iterating over parents or children.
  # Additionally, not every child will need a parent or they might not need a parent at initialization.
  class HashTree
    ##
    # Create a hash tree.
    def initialize
      @parent_keys = {}
      @child_keys = {}
    end

    ##
    # Add child associated with parent(s).
    def add(child, parents)
      unless @child_keys.key?(child)
        @child_keys[child] = {
          value: nil,
          parents: []
        }
      end
      @child_keys[child][:parents] += [*parents]
      [*parents].each do |parent|
        @parent_keys[parent] = [] unless @parent_keys.key?(parent)
        @parent_keys[parent] << child
      end
    end

    ##
    # Add parent with no children.
    def add_parent(parents)
      [*parents].each do |parent|
        @parent_keys[parent] = [] unless @parent_keys.key?(parent)
      end
    end

    ##
    # Add child with no value and no parents.
    def add_child(children)
      [*children].each do |child|
        next if @child_keys.key?(child)
        @child_keys[child] = {
          value: nil,
          parents: []
        }
      end
    end

    ##
    # Set value of child.
    def set_child_value(child, value)
      @child_keys[child][:value] = value
    end

    ##
    # Get value of child.
    def get_child_value(child)
      @child_keys[child][:value]
    end

    ##
    # Get child's parents
    def get_parents(child)
      @child_keys[child][:parents]
    end

    ##
    # Get parent's children
    def get_children(parent)
      @parent_keys[parent]
    end

    ##
    # Collect values of children for parent.
    def get_values(parent)
      vals = {}
      @parent_keys[parent].each do |child|
        vals[child] = @child_keys[child][:value]
      end
      vals
    end

    ##
    # Get parents hash.
    def parents
      @parent_keys.dup
    end

    ##
    # Get children hash.
    def children
      @child_keys.dup
    end

    ##
    # Does element exist as a child and/or parent key?
    def has?(element)
      @parent_keys.key?(element) || @child_keys.key?(element)
    end

    ##
    # Is element a child?
    def child?(element)
      @child_keys.key?(element)
    end

    ##
    # Is element a parent?
    def parent?(element)
      @parent_keys.key?(element)
    end

    ##
    # Delete child. Removes references to child in associated parents.
    def delete_child(element)
      if @child_keys.key?(element)
        @child_keys[element][:parents].each do |parent|
          @parent_keys[parent] -= [element]
        end
        @child_keys.delete element
      end
    end

    ##
    # Delete parent. Removes references to parent in associated children.
    def delete_parent(element)
      if @parent_keys.key?(element)
        @parent_keys[element].each do |child|
          @child_keys[child][:parents] -= [element]
        end
        @parent_keys.delete element
      end
    end

    ##
    # Delete from parents and children. Essentially removes all known references.
    def delete(element)
      delete_child(element)
      delete_parent(element)
    end

    ##
    # Finds children without parents. Returned as hash.
    def orphans
      @child_keys.select { |_key, info| info[:parents].empty? }
    end

    ##
    # Finds parents without children. Returned as hash.
    def childless
      @parent_keys.select { |_key, children| children.empty? }
    end
  end
end
