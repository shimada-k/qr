# -*- encoding: UTF-8 -*-
require 'sinatra'
require 'json'
require 'mysql'
require 'kconv'

class QrModel

	def initialize()
		@con = Mysql::connect('127.0.0.1', 'root', 'nbiaReh7', 'qr')
		sql = 'SET NAMES utf8'
		@con.query sql
    end

	def debug(str)
		f = File.open('test', 'a')
		f.print str
		f.print "\n"
		f.flush
		f.close
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
		record['created_at'] = Time.now.strftime("%Y-%m-%d %H:%M:%S")
        array = value_serialize(record)

        sql = 'INSERT INTO checkin_history' + ' (' + record.keys.join(',') + ') ' + 'values (' + array.join(',') +  ');'
		#self::debug(sql)
        @con.query sql
	end

	def searchHistoryByUserId(user_id)
        sql = 'SELECT * FROM checkin_history' << ' WHERE user_id = \'' << user_id << '\';'
		data = Hash.new
		#self::debug(sql)
		checkin_items = Array.new
        records = @con.query sql

        while(item = records.fetch_hash())
			item["venue_name"] = item["venue_name"].force_encoding("UTF-8")
			#print item["venue_name"]
            checkin_items.push(item)
			#self::debug(item)
        end

		data["count"] = checkin_items.length
		data["items"] = checkin_items

		#self::debug(data)

		JSON.generate(data)
	end

	def searchHistoryByCheckinId(checkin_id)
        sql = 'SELECT * FROM checkin_history' << ' WHERE checkin_id = \'' << checkin_id << '\';'
		data = Hash.new
		#self::debug(sql)
		checkin_items = Array.new
        records = @con.query sql

        while(item = records.fetch_hash())
			item["venue_name"] = item["venue_name"].force_encoding("UTF-8")
			#print item["venue_name"]
            checkin_items.push(item)
			#self::debug(item)
        end

		data["count"] = checkin_items.length
		data["items"] = checkin_items

		#self::debug(data)

		JSON.generate(data)
	end

	def searchHistoryByUserIds(user_ids)

        sql = 'SELECT * FROM checkin_history' << 
			' WHERE user_id in ('<< user_ids.join(',') << ');'
		data = Hash.new
		#self::debug(sql)
		checkin_items = Array.new
        records = @con.query sql

        while(item = records.fetch_hash())
			item["venue_name"] = item["venue_name"].force_encoding("UTF-8")
			#print item["venue_name"]
            checkin_items.push(item)
			#self::debug(item)
        end

		data["count"] = checkin_items.length
		data["items"] = checkin_items

		#self::debug(data)

		JSON.generate(data)
	end
end

#model = QrModel.new
#model.searchHistoryByUserId("43385048")

post '/test' do
	model = QrModel.new
	#model.debug(params)

	#model.debug("\nnow, insertHistory")
	model.insertHistory(params)
end

get '/searchHistoryByUserId' do
	model = QrModel.new
	#model.debug(params[:user_id])
	checkins = model.searchHistoryByUserId(params[:user_id])
end

get '/searchHistoryByCheckinId' do
	model = QrModel.new
	#model.debug(params[:user_id])
	checkins = model.searchHistoryByCheckinId(params[:checkin_id])
end

get '/searchHistoryByUserIds' do
	model = QrModel.new
	model.debug(params[:user_ids])
	model.debug(JSON.parse(params[:user_ids]))
	#if(params[:user_ids].length != 0)
		checkins = model.searchHistoryByUserIds(JSON.parse(params[:user_ids]))
	#end
end

get '/' do
	'hello'
end
