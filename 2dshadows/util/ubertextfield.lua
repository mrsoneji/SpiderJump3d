-------------------------------------------------
-- ubertextuberTextField.lua
-- Displays a convenient and styleable input textfield widget
--
-- @module UberTextField
-- @author René Aye
-- @version 1.2
-------------------------------------------------

local logger        = require( "devilsquid.util.logger" )
local Helper       	= require( "devilsquid.util.helper" )

local UberTextField = {}

local _W    			= math.floor( display.actualContentWidth + 0.5 )
local _H    			= math.floor( display.actualContentHeight + 0.5 )
local _W2   			= _W * 0.5
local _H2   			= _H * 0.5
local _W4   			= _W2 * 0.5
local _H4   			= _H2 * 0.5

logger.setLogLevel( logger.LEVELS.WARNING, "UberTextField" )


-------------------------------------------------
-- Constructor function of UberTextField module
--
-------------------------------------------------
function UberTextField:new(options)
	logger.log("UberTextField", "new()" )

	local uberTextField = display.newGroup()
	
	uberTextField.isHidden 				= false
	uberTextField.hasValidationError 	= false
	uberTextField.type 					= "ubertextfield"

	uberTextField.originalViewPosition 	= nil 		-- the y value of the original view before it has been changed by uberTextField to brign the textField into view
	uberTextField.viewMoved				= 0 		-- stores the yMovement of a view, when the view has to be moved up, to move
													-- the textField into view

	-- get options
	local options 				= options or {}
	local opt					= {}

	opt.left 					= options.left or 0 						-- left position
	opt.top 					= options.top or 0 							-- top position
	opt.x 						= options.x or 0 							-- x position
	opt.y 						= options.y or 0 							-- y posiiton
	opt.width 					= options.width or (display.contentWidth * 0.75) 	-- width
	opt.height 					= options.height or 20	 					-- height
	opt.id 						= options.id 								-- id that can be used in the event handler
	opt.name 					= options.name 								-- can be used for validation hints to the user
	opt.listener 				= options.listener or nil 					-- the event listener
	opt.text 					= options.text or "" 						-- the display text
	opt.inputType 				= options.inputType or "default" 			-- input type (cn be 'default' or 'number')
	opt.font 					= options.font or native.systemFont 		-- the font
	opt.fontSize 				= options.fontSize or opt.height * 0.67 	-- font size
	opt.isSecure 				= options.isSecure or false 				-- if it is a secure (password) field
	opt.placeholder 			= options.placeholder or "" 				
	opt.returnKey 				= options.returnKey or "default"
	opt.resizeHeightToFitFont 	= options.resizeHeightToFitFont or 0
	opt.align 					= options.align or "left"
	opt.mandatory 				= options.mandatory or false
	opt.maxLength 				= options.maxLength or 0
	opt.minLength 				= options.minLength or 0
	opt.errorColor 				= options.errorColor or { 1, 0, 0, 1 }
	opt.parentView 				= options.parent or nil
	opt.nextTextField 			= options.nextTextField or nil
	opt.resetView 				= options.resetView or false 				-- if is true then reset the parent view to its original state
	opt.unfocusKeyboardObjects 	= options.unfocusKeyboardObjects or nil 	-- table of objects that should listen to a touch to hide the keyboard
 	opt.padding 				= options.padding or 40
 	opt.paddingLeft				= options.paddingLeft or opt.padding
 	opt.paddingRight			= options.paddingRight or opt.padding

	-- Vector options
	opt.strokeWidth 			= options.strokeWidth or 2
	opt.cornerRadius 			= options.cornerRadius or opt.height * 0.33 or 10
	opt.strokeColor 			= options.strokeColor or { 0, 0, 0, 1  }
	opt.backgroundColor 		= options.backgroundColor or { 1, 1, 1, 1 }

	-- copy the options to the object
	uberTextField.options 		= opt

	-- CREATE THE WIDGET ---------------------------------------------------

	uberTextField.background = display.newRoundedRect( 0, 0, opt.width, opt.height, opt.cornerRadius )
	uberTextField.background:setFillColor( unpack(opt.backgroundColor) )
	uberTextField.background.strokeWidth = opt.strokeWidth
	uberTextField.background.stroke = opt.strokeColor
	uberTextField:insert( uberTextField.background )

	-- POSITIONING ---------------------------------------------------

	if ( opt.x ) then
	   uberTextField.x = opt.x
	end
	if ( opt.left ) then
	   uberTextField.x = opt.left + opt.width * 0.5
	end
	if ( opt.y ) then
	   uberTextField.y = opt.y
	end
	if ( opt.top ) then
	   uberTextField.y = opt.top + opt.height * 0.5
	end

	-- Native UI element
	local tHeight = opt.height - opt.strokeWidth * 2
	if "Android" == system.getInfo("platformName") then
	    --
	    -- Older Android devices have extra "chrome" that needs to be compensated for.
	    --
	    tHeight = tHeight + 10
	end

	-- CREATE THE TEXT FIELD ---------------------------------------------------
	local tWidth = opt.width - opt.paddingLeft - opt.paddingRight

	uberTextField.textField 				= native.newTextField( 0, 0, tWidth, tHeight )
	uberTextField.textField.x 				= -((opt.width - tWidth)/2) + opt.paddingLeft
	uberTextField.textField.y 				= 0
	uberTextField.textField.hasBackground 	= false
	uberTextField.textField.inputType 		= opt.inputType
	uberTextField.textField.text 			= opt.text
	uberTextField.textField.isSecure 		= opt.isSecure
	uberTextField.textField.placeholder		= opt.placeholder
	uberTextField.textField.align 			= opt.align
	uberTextField.textField:setReturnKey( opt.returnKey )
	uberTextField:insert(uberTextField.textField)

	-- ADD LISTENER ACTION ---------------------------------------------------

	if opt.listener ~= nil and type(opt.listener)  == "function" then
		uberTextField.textField:addEventListener( "userInput", opt.listener )
	end
	uberTextField.textField:addEventListener( "userInput", function(event) uberTextField:uberTextFieldListener(event) end)

	uberTextField.textField.font = native.newFont( opt.font, opt.fontSize )
	uberTextField.textField.size = opt.fontSize

	if opt.resizeHeightToFitFont == true then 
		uberTextField.textField.size = nil
		uberTextField.textField:resizeHeightToFitFont()
	end


	-- ADD THE UNFOCUS KEYBOARD LISTENER ---------------------------------------------------

	-- set the unfocus listener to all objects that should remove the keyboard when tapped

	if opt.unfocusKeyboardObjects ~= nil then
		if type( opt.unfocusKeyboardObjects ) == "table" then
			for i=1,#opt.unfocusKeyboardObjects do
				opt.unfocusKeyboardObjects[i]:addEventListener( "tap", function() 
					native.setKeyboardFocus( nil ); 

						if uberTextField.options.parentView ~= nil then
							if uberTextField.originalViewPosition ~= nil then
	
								print("UBERTEXTFIELD::reset view", uberTextField.originalViewPosition )
								uberTextField.options.parentView.y = uberTextField.originalViewPosition

							end
						end

					end )
			end
		end
	end


	-------------------------------------------------
	-- PRIVATE FUNCTIONS
	-------------------------------------------------


	function uberTextField:uberTextFieldListener( event )
		logger.log("UberTextField", "uberTextField:uberTextFieldListener")

		-- PHASE: BEGAN ------------------------------

		if ( event.phase == "began" ) then
			if self.options.parentView ~= nil then
		
				if self.originalViewPosition == nil then
					self.originalViewPosition = self.options.parentView.y
					print( "uberTextField.originalViewPosition", self.originalViewPosition )
				end

			end

			--make sure the field is in view
			
			-- get screen coordinates of textField
			local screenX, screenY = self:localToContent(0,0)

			-- where should the textField be
			local topEdge 	= 200
			local bottomEdge = _H2

			-- calculate difference if text field is above the edge (too high)
			if screenY < topEdge then
				self.viewMoved = screenY - topEdge

				if self.options.parentView then
					transition.to( self.options.parentView, {time=150, y=self.options.parentView.y-self.viewMoved, transition=easing.outQuad})
				end

			-- calculate difference if text field is above the edge (too high)
			elseif screenY > bottomEdge then
				self.viewMoved = screenY - bottomEdge

				if self.options.parentView then
					transition.to( self.options.parentView, {time=150, y=self.options.parentView.y-self.viewMoved, transition=easing.outQuad})
				end
			end


			

		-- PHASE: EDITING ------------------------------
			
		elseif ( event.phase == "editing" ) then
	        --print( event.newCharacters )

	        if self.options.inputType == "number" then
		        if tonumber(event.newCharacters) == nil then
		        	event.target.text = string.sub(event.target.text, 0, string.len(event.target.text)-1)
		        end
		    end

	        if self.options.maxLength > 0 then
		        if string.len(event.target.text) > self.options.maxLength then
		        	event.target.text = string.sub(event.target.text, 0, self.options.maxLength)
		        end
		    end
		end



		-- PHASE: SUBMITTED ------------------------------

		-- jump to next textField or close KeyBoard 
		if ( event.phase == "submitted" ) then

			-- if input is finished then close keyboard
			if self.options.returnKey == "done" then

				native.setKeyboardFocus( nil )

			-- jump to next TextField
			else
				-- if a nextTextField is set
				if self.nextTextField ~= nil then
					
					if self.nextTextField.type == "ubertextfield" then
						self.nextTextField.originalViewPosition = self.originalViewPosition
						native.setKeyboardFocus( self.nextTextField.textField )
					else
						native.setKeyboardFocus( self.nextTextField )
					end
				else
					print("UberTextField - no next NextTextField set")
				end
			end
	    end


		-- PHASE: ENDED ------------------------------

		-- jump to next textField or close KeyBoard 
		if ( event.phase == "ended" ) then

			native.setKeyboardFocus( nil )

			if self.options.resetView == true then
				if self.options.parentView ~= nil then
					print("UBERTEXTFIELD::reset view", self.originalViewPosition )
					self.options.parentView.y = self.originalViewPosition
				end
			end
		end

		return true
	end


	-----------------------------------------------------------------------------
	-- Hides the whole uberwidget so it does not overlay other elements
	-- by movin the textField widget out of view
	-----------------------------------------------------------------------------
	function uberTextField:Hide(  )
		logger.log("UberTextField", "uberTextField:Hide")
		self.isHidden = true
		self.textField.y = _H * 1000
		self.background.alpha = 0
	end

	-----------------------------------------------------------------------------
	-- Shows the textfield widget again
	-----------------------------------------------------------------------------
	function uberTextField:Show(  )
		logger.log("UberTextField", "uberTextField:Show")
		self.isHidden = false
		self.textField.y = 0
		self.background.alpha = 1
	end


	-----------------------------------------------------------------------------
	-- Hides the textfield widget only so it does not overlay other elements
	-- by movin the textField widget out of view
	-----------------------------------------------------------------------------
	function uberTextField:HideTextField(  )
		logger.log("UberTextField", "uberTextField:Hide")
		self.isHidden = true

		local screenX, screenY = self:localToContent(0,0)
		local delay = screenY/_H * 150

		timer.performWithDelay( delay, function() self.textField.y = _H * 1000 end  )
	end


	-----------------------------------------------------------------------------
	-- Sets mandatory on or off
	-----------------------------------------------------------------------------
	function uberTextField:SetMandatory( isMandatory )
		logger.log("UberTextField", "uberTextField:SetMandatory", isMandatory)
		self.options.mandatory = isMandatory
	end


	-----------------------------------------------------------------------------
	-- Gets the textfields text
	-----------------------------------------------------------------------------
	function uberTextField:GetText()
		logger.log("UberTextField", "uberTextField:GetText")
		return self.textField.text
	end

	-----------------------------------------------------------------------------
	-- Shows the textfield widget again
	-----------------------------------------------------------------------------
	function uberTextField:SetText( txt )
		logger.log("UberTextField", "uberTextField:SetText")
		self.textField.text = txt
	end

	-----------------------------------------------------------------------------
	-- Shows the textfield widget again
	-----------------------------------------------------------------------------
	function uberTextField:SetPlaceholderText( txt )
		logger.log("UberTextField", "uberTextField:SetPlaceholderText")
		self.textField.placeholder = txt
	end

	-----------------------------------------------------------------------------
	-- Sets the width of the textfield
	-----------------------------------------------------------------------------
	function uberTextField:SetWidth( width )
		logger.log("UberTextField", "uberTextField:SetWidth", width)
		self.textField.width = width - self.options.cornerRadius - self.options.paddingLeft - self.options.paddingRight
		self.background.width = width
	end


	-----------------------------------------------------------------------------
	-- marks a validation error in color
	-----------------------------------------------------------------------------
	function uberTextField:MarkValidationError( showError )
		self.hasValidationError = showError

		if showError == true then
			self.background:setStrokeColor( unpack(self.options.errorColor) )
		else
			self.background:setStrokeColor( unpack(self.options.strokeColor) )
		end
	end


	-----------------------------------------------------------------------------
	-- Validates the text field
	-----------------------------------------------------------------------------
	function uberTextField:Validate( options )
		if self.isHidden == false then
			local txt = self.textField.text
			local name = self.options.name or nil
			if name == nil and self.options.placeholder ~= nil then
				name = self.options.placeholder
			end

			local opt 		= {}
			opt.viewToMove 	= options.viewToMove or nil
			opt.check 		= options.check or "empty" 						-- can be "empty", "email", "number", "positivenumber"
			opt.errHeadline = options.errorHeadline or "Validation Error"
			opt.errMsg 		= options.errorMessage or nil
			opt.length 		= options.length or 0
			opt.minLength 	= options.minLength or self.options.minLength
			opt.maxLength 	= options.maxLength or 0
			opt.alreadyExists = options.alreadyExists or nil 				-- can be used to check if the value is not allowed due the text does already exists

			if self.options.mandatory == true then
				if txt == nil or txt == "" then
					local errorData = {
						headline = opt.errHeadline,
						message = opt.errMsg or "The field " .. name .. " is mandatory!"
					}

					self:MarkValidationError( true )
					return false, errorData
			    else
			    	self:MarkValidationError( false )
				end
			end

			if opt.length > 0 then
				if string.len( txt ) ~= opt.length then
					local errorData = {
						headline = opt.errHeadline,
						message = opt.errMsg or "The value in the field " .. name .. " must have exact " .. opt.maxLength .. " symbols."
					}

			    	self:MarkValidationError( true )
			    	return false, errorData
				end
			end

			if opt.minLength > 0 then
				if string.len( txt ) < opt.minLength then
					local errorData = {
						headline = opt.errHeadline,
						message = opt.errMsg or "The value in field " .. name .. " is shorter than " .. opt.minLength .. " symbols."
					}

			    	self:MarkValidationError( true )
			    	return false, errorData
			    else
			    	self:MarkValidationError( false )
				end
			end

			if opt.maxLength > 0 then
				if string.len( txt ) > opt.maxLength then
					local errorData = {
						headline = opt.errHeadline,
						message = opt.errMsg or "The value in field " .. name .. " is longer than " .. opt.maxLength .. " symbols."
					}

			    	self:MarkValidationError( true )
			    	return false, errorData
			    else
			    	self:MarkValidationError( false )
				end
			end

			if opt.alreadyExists ~= nil then
				for k,v in pairs(opt.alreadyExists) do
					if txt == v then
						local errorData = {
							headline = opt.errHeadline,
							message = opt.errMsg or "The value does already exist."
						}

						self:MarkValidationError( true )
			    		return false, errorData
					else
						self:MarkValidationError( false )
					end
				end
			end

			if opt.check == "empty" then
				if txt == nil or txt == "" then
					local errorData = {
						headline = opt.errHeadline,
						message = opt.errMsg or "The field " .. name .. " is empty."
					}

					self:MarkValidationError( true )
					return false, errorData
			    else
			    	self:MarkValidationError( false )
				end
			end

			if opt.check == "email" then
			    if ( txt:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?") ) then
			    	self:MarkValidationError( false )
			       	return true

			    else

					local errorData = {
						headline = opt.errHeadline,
						message = opt.errMsg or "The field " .. name .. " must be a valid email address."
					}

			    	return false, errorData
			    end
			end

			if opt.check == "number" then
				if tonumber(txt) == nil then
					local errorData = {
						headline = opt.errHeadline,
						message = opt.errMsg or "The value in the field " .. name .. " must be a number."
					}

			    	self:MarkValidationError( true )
			    	return false, errorData
			    else
			    	self:MarkValidationError( false )
				end
			end

			if opt.check == "positivenumber" then
				if tonumber(txt) == nil and tonumber(txt) > 0 then
					local errorData = {
						headline = opt.errHeadline,
						message = opt.errMsg or "The value in the field " .. name .. " must be a positive number."
					}

			    	self:MarkValidationError( true )
			    	return false, errorData
			    else
			    	self:MarkValidationError( false )
				end
			end

		end

		return true
	end



	return uberTextField
end
 
return UberTextField