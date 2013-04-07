require 'rubygems'
require 'mysql'
require 'json'

class QrModel

    def initialize()
        @con = Mysql::connect('127.0.0.1', 'root', 'nbiaReh7', 'qr')
        sql = 'SET NAMES utf8'
        @con.query sql
    end

   def value_serialize(record)
        ret = Array.new()
        str = String.new()

        record.each_value {|value|

            if(value.instance_of?(String))
            then
                value.gsub!(/'/) do |m|
                    '\\' << m
                end
                str = '\'' << value << '\''
            else
                    str = value
            end

            ret.push(str)
        }
        return ret
    end


	def insertHistory(record)
        array = value_serialize(record)

        sql = 'INSERT INTO checkin_history' + ' (' + record.keys.join(',') + ') ' + 'values (' + array.join(',') +  ');'
        #p sql
        @con.query sql
	end


	def searchHistoryByUserId(user_id)
        sql = 'SELECT * FROM checkin_history' << ' WHERE user_id = \'' << user_id << '\';'
		ret_hash_array = Array.new

        #p sql
        records = @con.query sql

        while(record = records.fetch_hash())
            ret_hash_array.push(record)
        end

		#p ret_hash_array

        JSON.generate(ret_hash_array)
	end
end

=begin
db = QrModel.new()

record = {'checkin_id' => 'hoge', 'latitude' => 'foo',
		'longitude' => 'bar', 'user_id' => 'baz',
		'enable_flag' => 1,
		'scaned_result' => 'http://hoge.hoge/', 'created_at' => '2013-01-08 00:00:00'}

#db.insertHistory(record);

db.searchHistoryByUserId('baz');
=end
