# coding: utf-8

module Ddeployer
  class FileList
    class << self
      def get_diff commit1, commit2
        list = FileList.new
        responce_cmd = `git diff --name-status #{commit1} #{commit2}`
        responce_cmd.each_line do |line|
          strs = line.chomp.split("\t")
          case strs[0]
          when "A","M"
            list.forward << strs[1]
          when "D"
            list.remove << strs[1]
          end
        end
        return list
      end

      def get_all
        list = FileList.new
        responce_cmd = `git ls-files`
        responce_cmd.each_line do |line|
          list.forward << line.chomp
        end
        return list
      end
    end

    def initialize
      @forward = []
      @remove = []
    end

    def initialize_copy obj
      @forward = obj.forward.dup
      @remove = obj.remove.dup
    end

    attr_accessor :forward, :remove
  end
end
