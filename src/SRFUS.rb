#!/usr/bin/env ruby

require 'net/ftp'
require 'io/console'

#
#	A script for uploading files via FTP to a server. 
#
#	Execute the script with the first arg as the server, login name, and login password separated by a space
#		Any details not provided will be requested from the user before any actions are taken
#
#	Each arg following the first arg should be the full path of a local file - there is no maximum number of args
#
#
# 	Batch File Example:
#
# 							START Script.rb "server username password" C:\Example\FileToUpload1.jpg C:\Example\FileToUpload2.avi
#
#

AUTHOR = "David Watson"
R_VERSION = "2.0.0"			#Ruby version used while creating/testing the script

SCRIPT_NAME = "Simple Ruby File Upload Script (SRFUS)"
SCRIPT_VERSION = "1.00"
SCRIPT_DATE = "15th September 2013"

START_MESSAGE = "#{SCRIPT_NAME} #{SCRIPT_VERSION}\nCreated on #{SCRIPT_DATE} by #{AUTHOR} with Ruby #{R_VERSION}\n\n"

STORAGE_FOLDER = "SRFUS"
DEBUG = false
FILE_SIZE_ACCURCY	= 3

MIN_ARGV_INDEX = 1
USER_INFO_INDEX = 0
ARGS_BEFORE_FILES = 1

ARGS_SERVER = 0
ARGS_USERNAME = 1
ARGS_PASSWORD = 2

def run()
	puts(START_MESSAGE)
	if ( ARGV[ MIN_ARGV_INDEX ] != nil )
	
		userInfo = ARGV[USER_INFO_INDEX].split( " " )
		
		server = nil
		username = nil
		password = nil
		
		if ( userInfo[ ARGS_SERVER ] != nil )
			server = userInfo[ ARGS_SERVER ]
		else
			server = RequestServer()
		end
		
		if ( userInfo[ ARGS_USERNAME ] != nil )
			username = userInfo[ ARGS_USERNAME ]
		else
			username = RequestUsername()
		end
		
		if ( userInfo[ ARGS_PASSWORD ] != nil  )
			password = userInfo[ ARGS_PASSWORD ]
		else
			#Console is cleared after password is input to prevent it from being visible on screen after the user has typed the password.
			password = RequestPassword()	
			ClearConsoleDisplay()
		end
		
		filesAmount = ARGV.length - ARGS_BEFORE_FILES;
		filesToUpload = [ filesAmount ]
		
		for i in 0..filesAmount
			filesToUpload[ i ] = ARGV[ i + ARGS_BEFORE_FILES ]
		end
		
		puts( "Attempting to login as '#{username}' at '#{server}'..." )
		
		UploadFiles( server, username, password, filesToUpload ) 
	else
		#Add 1 to MIN_ARGV_INDEX because it counts from 0 rather than at 1
		puts("Script received less than #{MIN_ARGV_INDEX + 1} arguments. \n")
		puts("Please ensure you send arguments of: \n\n 1) server name password \n 2) First file to upload \n 3) Second file to upload... \n\n")
		puts("(in that order) for the script to work correctly.")
	end
	
	FinishScript()
end

def ClearConsoleDisplay()
	system( "cls" )
end

def RequestServer()
	puts( "Please enter the domain name/IP address of the machine you wish to upload too. " )
	server = STDIN.gets.gsub( "\n", "" )
	return server
end

def RequestUsername()
	puts( "Please enter login name you wish to use: " )
	username = STDIN.gets.gsub( "\n", "" )
	return username
end

def RequestPassword()
	puts( "Please enter password for the provided login name: " )
	password = STDIN.gets.gsub( "\n", "" )
	return password
end

def UploadFiles( server, user, password, localFilesList )
	begin
		ftp = Net::FTP.new
		ftp.passive = true
		ftp.connect( server )
		ftp.login( user, password )
		
		currentYear = GetYear()
		currentMonth = GetMonth()
		currentTimeAndDay = GetDay() + " at " + GetTime()
		folderStructure = [ STORAGE_FOLDER, currentYear, currentMonth, currentTimeAndDay ]	#Folder structure for storing remote file (left to right)
		
		folderStructure.each do |folder| 
			begin
				ftp.chdir(folder)		#if the directory does not already exist then this will fail
			rescue
				ftp.mkdir(folder)		#this only occurs if the directory does not exists - so create it
				ftp.chdir(folder)		#chdir once the directory is now created
			end
		end
		
		#Upload each file to the current directory
		localFilesList.each do |localFile|
			if(localFile != nil)
				if ( File.exists?( localFile ) )
					fileName = File.basename(localFile)
					fileSize = GetFileSizeInMB(localFile)
					
					puts( "\nPlease wait while #{fileName} (#{fileSize}MB) is uploaded..." )
		
					ftp.putbinaryfile( localFile, fileName )
						
					puts(ftp.last_response)
				else
					puts("\nFile does not exist: #{localFile}")
					puts("Failed!\n")
				end
			end
		end
		
		ftp.quit()
		
	rescue Exception => ex
		puts ex.message
		if( DEBUG )
			puts ex.backtrace.join("\n")
		end
	end
	
end

def GetFileSizeInMB(file)
	if ( File.exists?( file ) )
		return ( File.size( file ).to_f / ( 2**20 ) ).round(FILE_SIZE_ACCURCY)
	else
		return 0.00
	end
end

def GetYear()
	currentTime = Time.new
	result = currentTime.strftime("%Y")
	return result
end

def GetMonth()
	currentTime = Time.new
	result = currentTime.strftime("%B")
	return result
end

def GetDay()
	currentTime = Time.new
	result = currentTime.strftime("%d %a")
	return result
end

def GetTime()
	currentTime = Time.new
	result = currentTime.strftime("%I_%M %p")
	return result
end

def FinishScript()
	puts("\n\n\nScript Finished! Press enter to exit.")
	STDIN.gets
end



#starts the script
begin
	run()
rescue Exception => ex
	#Display any errors in the script to the user.
	puts ex.message
	if( DEBUG )
		puts ex.backtrace.join("\n")
	end
	FinishScript()
end
