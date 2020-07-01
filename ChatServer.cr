#Author: Multie
#Simple chat server written in Crystal language
#capable to broadcast messages to all that are connected
#also capable of sending private messages

require "socket"

PORT=12333

class Connection
	property socket : TCPSocket

	def initialize(@socket)
	end

	def send_message(message)
		socket.puts(message)
	end

end

class Server
	property clients = Array(Connection).new

	def handle_connection(socket)
		puts "New connection: #{socket}"

		temp_client = Connection.new(socket)
		clients << temp_client

		#Gives a ID as username
		n1 = temp_client.object_id
		user_id = n1.to_s
		puts "Client " + user_id + " has connected."

		temp_client.send_message("Clients connected: #{clients.size}")
		temp_client.send_message("To send private message use the following format:\n")
		temp_client.send_message("/w <ID> <MESSAGE>\n")
		temp_client.send_message("Your ID:" + user_id + "\n")

		loop do
			rec_message = socket.gets
			new_message = rec_message.to_s

			if new_message.starts_with?("/w")
				m = new_message.split(' ')
				send_to_id = m[1]
				m.delete_at(0)
				m.delete_at(0)
				msg = user_id + " sent: " + m.join(' ')
				clients.each do |obj|
					str = obj.object_id
					str2 = str.to_s
					if str2 == send_to_id
						obj.send_message(msg)
					end
				end
			elsif new_message === "/c"
				temp_client.send_message("Clients connected: #{clients.size}")
			else
				clients.each do |x|
					x.send_message("BROADCAST: " + new_message)
				end
			end

		end
	rescue e
		puts "Client " + temp_client.object_id.to_s + " has disconnected"
		clients.delete temp_client
		puts "Client connected: #{clients.size}"
	end

	def initialize
		puts "Server is listening on port #{PORT}..."

		server = TCPServer.new(PORT)

		while socket = server.accept?
			spawn handle_connection(socket)
		end

	end

end

Server.new