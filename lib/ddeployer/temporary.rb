# coding: utf-8
require 'digest/md5'
require 'ddeployer/constants'

module Ddeployer
  class Temporary
    attr_accessor :file
    def initialize repo
      @file = "#{APP_SAVE_DIR}/tmp/#{repo.name}-#{repo.branch}-#{repo.hash}"
    end

    def exist?
      return File.exist?(@file)
    end

    def get_last
      obj = nil
      if exist? then
        open("|tail -n 1 < #{@file}") do |fi|
          line = fi.gets(nil)
          strs = line.chomp.split("\t")
          obj = {
            :time => strs[0],
            :hash => strs[1]
          }
        end
      else
        puts 'not exist'
      end
      return obj
    end

    def write_log rev
      File.open(@file, 'a') do |file|
        file.puts("#{Time.now.to_s}\t#{rev}")
      end
    end

    def show_log
      puts 'show log'
    end
  end
end
