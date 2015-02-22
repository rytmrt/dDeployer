# coding: utf-8

module Ddeployer
  class Repository
    def initialize path, branch
      @path = path
      @name = File.basename(@path)
      @hash = Digest::MD5.new.update(@path).to_s
      @head = `git rev-parse HEAD`.chomp
      @branch = branch
    end
    attr_reader :path, :name, :hash, :head, :branch
  end
end
