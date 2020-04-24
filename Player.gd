# marcmeinhardt 05/04/2020
# keep going ! 

extends KinematicBody

# PHYSICS - : Key Words
# speed        = the rate at which an object covers a distance
# velocity     = the rate at which an object changes position
# acceleration = the rate at which an object changes velocity

# MARKUP - : Properties

# VARIABLES : physics & movement processes
const acceleration   = 20
const sprintAccel    = 25
const deacceleration = 40
const gravity        = -9.81 # gravity
const jumpSpeed      = 120 
const maxSpeed       = 25
const maxSprintSpeed = 65
const maxSlopeAngle  = 70
# steepest angle our KinematicBody will consider as a ‘floor’
var velocity         = Vector3()
var direction        = Vector3()
var camera
var rotationHelper
var isSprinting      = false
var flashlight

# VARIABLES : user weapons
const weaponNameToNumber = {"unarmed" : 0, "knife" : 1, "pistol" : 2, "rifle" : 3}
const weaponNumberToName = {0 : "unarmed", 1 : "knife", 2 : "pistol", 3 : "rifle"}

var animationManager
var currentWeaponName   = "unarmed"
var weapons             = {"unarmed" : null, "knife" : null, "pistol" : null, "rifle" : null}
var changingWeapon      = false
var changingWeaponName  = "unarmed"
var reloadingWeapon = false

# VARIABLES : user stats
const maxHealth = 501
var health = 100
var UiStatusLabel 

# VARIABLES : simple audio player 3d
var simpleAudioPlayer = preload("res://Simple_Audio_Player.tscn")

# VARIABLES : mouse scroll 
const mouseScrollWheelSensitivity = 0.08
var mouseSensitivity = 0.05
var mouseScrollValue = 0

# VARIABLES : joypad / controller
const joyPadDeadZone = 0.15
var joyPadSensitivity = 2


# MARKUP - : Ready
func _ready():
   camera = $Rotation_Helper/Camera
   rotationHelper = $Rotation_Helper
   
   animationManager = $Rotation_Helper/Model/Animation_Player
   animationManager.callBackFunction = funcref(self, "fireBullet")
   
   Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
   
   weapons["knife"]  = $Rotation_Helper/Gun_Fire_Points/Knife_Point
   weapons["pistol"] = $Rotation_Helper/Gun_Fire_Points/Pistol_Point
   weapons["rifle"]  = $Rotation_Helper/Gun_Fire_Points/Rifle_Point
   
   var gunAimPointPos = $Rotation_Helper/Gun_Aim_Point.global_transform.origin
   
   for weapon in weapons :
      var weaponNode = weapons[weapon]
      if weaponNode  != null :
         weaponNode.playerNode = self
         weaponNode.look_at(gunAimPointPos, Vector3(0, 1, 0))
         weaponNode.rotate_object_local(Vector3(0, 1, 0), deg2rad(180))
   
   currentWeaponName    = "unarmed"
   changingWeaponName   = "unarmed"
   
   flashlight     = $Rotation_Helper/Flashlight
   UiStatusLabel  = $HUD/Panel/Gun_label


# MARKUP - : Functions
# 1. create all physics processes   
func _physics_process(delta) :
   process_input(delta)
   process_movement(delta)
   processChangingWeapons(delta)
   processReloading(delta)
   processUi(delta)
   processInputView(delta)
   #print(Input.get_joy_axis(0, JOY_AXIS_0)) prints the output of a connected controller
   

# 2. process all player input  
# warning-ignore:unused_argument
func process_input(delta) :
   
   # ACTION - : Walking
   direction = Vector3()
   
   # get global world space vectors
   var cam_xform = camera.get_global_transform()
   var input_movement_vector = Vector2()
   
   if Input.is_action_pressed("movement_forward") :
      input_movement_vector.y += 1
      #node.translate(Vector3(0, 0, 1))
   if Input.is_action_pressed("movement_backward") :
      input_movement_vector.y -= 1
      #node.translate(Vector3(0, 0, -1))
   if Input.is_action_pressed("movement_left") :
      input_movement_vector.x -= 1
      #node.translate(Vector3(1, 0, 0))
   if Input.is_action_pressed("movement_right") :
      input_movement_vector.x += 1
      #node.translate(Vector3(-1, 0 , 0))
      
   # FIX - : controller support and axis movement to be fixed   
   # joypad input if present
   if Input.get_connected_joypads().size() > 0 :
      
      var joyPadVector = Vector2(0, 0)
      
      if OS.get_name() == "Windows" :
         joyPadVector = Vector2(Input.get_joy_axis(0, 0), Input.get_joy_axis(0, 1))
      elif OS.get_name() == "X11" :
         joyPadVector = Vector2(Input.get_joy_axis(0, 1), Input.get_joy_axis(0, 2))
      elif OS.get_name() == "OSX" :
         joyPadVector = Vector2(Input.get_joy_axis(0, 1), Input.get_joy_axis(0, 2))
      
      if joyPadVector.length() < joyPadDeadZone :
         joyPadVector = Vector2(0, 0)
      else : 
         joyPadVector = joyPadVector.normalized() * ((joyPadVector.length() - joyPadDeadZone) / (1 - joyPadDeadZone))
         
      input_movement_vector += joyPadVector  
   
   # normalize vectors places vectors within a 1 radius unit circle
   input_movement_vector = input_movement_vector.normalized()
     
   # Basis vectors are already normalized (idk what this means yet)
   direction += -cam_xform.basis.z*input_movement_vector.y
   direction += cam_xform.basis.x*input_movement_vector.x
   
   # ACTION - : Sprinting
   if Input.is_action_pressed("movement_sprint") :
      isSprinting = true
   else:
      isSprinting = false
   
   # ACTION - : Jumping
   if is_on_floor() :
      if Input.is_action_pressed("movement_jump") :
         velocity.y = jumpSpeed
         
   # ACTION - : Flashlight
   if Input.is_action_just_pressed("flashlight") :
      if flashlight.is_visible_in_tree():
         flashlight.hide()
      else:
         flashlight.show()
   
   # ACTION - : Esc
   if Input.is_action_just_pressed("ui_cancel") :
      if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE :
         Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
      else:
         Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

   # ACTION - : Changing weapons
   var weaponChangeNumber = weaponNameToNumber[currentWeaponName]
   
   if Input.is_key_pressed(KEY_1) :
      weaponChangeNumber = 0
   if Input.is_key_pressed(KEY_2) : 
      weaponChangeNumber = 1
   if Input.is_key_pressed(KEY_3) :
      weaponChangeNumber = 2
   if Input.is_key_pressed(KEY_4) :
      weaponChangeNumber = 3
      
   if Input.is_action_just_pressed("shift_weapon_positive") :
      weaponChangeNumber += 1
   if Input.is_action_just_pressed("shift_weapon_negative") :
      weaponChangeNumber -= 1
   
   # clamps value and returns a value not less than min and not more than max.
   weaponChangeNumber = clamp(weaponChangeNumber, 0, weaponNumberToName.size() -1)
   
   # check if user is changing weapon
   if changingWeapon == false : 
      if reloadingWeapon == false :
         if weaponNumberToName[weaponChangeNumber] != currentWeaponName :
            changingWeaponName = weaponNumberToName[weaponChangeNumber]
            changingWeapon = true
            mouseScrollValue = weaponChangeNumber
   
   # ACTION - : Firing weapons
   if Input.is_action_pressed("fire") : 
      if reloadingWeapon == false :
         if changingWeapon == false :
            var currentWeapon = weapons[currentWeaponName]
            if currentWeapon != null :
               if currentWeapon.ammoInWeapon > 0 :
                  if animationManager.currentState == currentWeapon.idleAnimationName :
                     animationManager.setAnimation(currentWeapon.fireAnimationName)
               else :
                  reloadingWeapon = true
                  
   # ACTION - : Reloading weapons
   if reloadingWeapon == false :
      if changingWeapon == false :
         if Input.is_action_just_pressed("reload") :
            var currentWeapon = weapons[currentWeaponName]
            if currentWeapon != null :
               if currentWeapon.canReload == true : 
                  var currentAnimationState = animationManager.currentState
                  var isReloading = false
                  for weapon in weapons : 
                     var weaponNode = weapons[weapon]
                     if weaponNode != null :
                        if currentAnimationState == weaponNode.reloadingAnimationName :
                           isReloading = true
                  if isReloading == false :
                     reloadingWeapon = true
                  
               
# 3. process movement data and send it to the Kinematicbody
func process_movement(delta):
   direction.y    = 0
   direction      = direction.normalized() 
   
   velocity.y     += gravity / delta * delta
   
   var velocityH  = velocity
   velocityH.y    = 0
   
   var target = direction
#   target *= maxSpeed
   
   var acceleration2 
   if direction.dot(velocityH) > 0 :
      acceleration2 = acceleration
   else:
      acceleration2 = deacceleration
      
   if isSprinting:
      target *= maxSprintSpeed
      acceleration2 = sprintAccel
   else:
      target *= maxSpeed
      acceleration2 = acceleration
      
   velocityH = velocityH.linear_interpolate(target, acceleration2 * delta)
   
   velocity.x = velocityH.x
   velocity.z = velocityH.z
   velocity = move_and_slide(velocity, Vector3(0, 1, 0), 0.05, 4, deg2rad(maxSlopeAngle))


# 4. process weapon changing
# warning-ignore:unused_argument
func processChangingWeapons(delta) :
   if changingWeapon == true :
      
      var weaponUnequipped = false
      var currentWeapon    = weapons[currentWeaponName]
      
      if currentWeapon == null :
         weaponUnequipped = true
      else :
         if currentWeapon.isWeaponEnabled == true :
            weaponUnequipped = currentWeapon.unequipWeapon()
         else :
            weaponUnequipped = true
            
      if weaponUnequipped == true :
                  
         var weaponEquiped = false
         var weaponToEquip = weapons[changingWeaponName]
         
         if weaponToEquip == null :
            weaponEquiped = true
         else :
            if weaponToEquip.isWeaponEnabled == false :
               weaponEquiped = weaponToEquip.equipWeapon()
            else : 
               weaponEquiped = true
               
         if weaponEquiped == true :
            changingWeapon = false
            currentWeaponName = changingWeaponName
            changingWeaponName = ""

# 5. process input events
func _input(event) :
   if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
      rotationHelper.rotate_x(deg2rad(event.relative.y * mouseSensitivity))
      self.rotate_y(deg2rad(event.relative.x * mouseSensitivity * -1))
   
   var cameraRotation = rotationHelper.rotation_degrees
   cameraRotation.x = clamp(cameraRotation.x, -70, 70)
   rotationHelper.rotation_degrees = cameraRotation
   
   if event is InputEventMouseButton and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED :
      if event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN :
         if event.button_index == BUTTON_WHEEL_UP :
            mouseScrollValue += mouseScrollWheelSensitivity
         elif event.button_index == BUTTON_WHEEL_DOWN :
            mouseScrollValue -= mouseScrollWheelSensitivity
         
         mouseScrollValue = clamp(mouseScrollValue, 0, weaponNumberToName.size() - 1)
         
         if changingWeapon == false :
            if reloadingWeapon == false :
               var roundMouseScrollValue = int(round(mouseScrollValue))
               if weaponNumberToName[roundMouseScrollValue] != currentWeaponName :
                  changingWeaponName = weaponNumberToName[roundMouseScrollValue]
                  changingWeapon = true
                  mouseScrollValue = roundMouseScrollValue
   
   
# 6. process bullet firing        
func fireBullet() :
   if changingWeapon == true :
      return
      # calling return stops the rest of the function from being called
      # we are not running the rest of the code & not looking for a returned variable either
      
   weapons[currentWeaponName].fireWeapon()


# 7. process bullet firing        
# warning-ignore:unused_argument
func processReloading(delta) :
   if reloadingWeapon == true :
      var currentWeapon = weapons[currentWeaponName]
      if currentWeapon != null : 
         currentWeapon.reloadWeapon()
      reloadingWeapon = false 

   
# 8. process UI
# warning-ignore:unused_argument
func processUi(delta) :
   if currentWeaponName == "unarmed" :
      UiStatusLabel.text = "hp : " + str(health) + "\nunarmed"
   elif currentWeaponName == "knife":
      UiStatusLabel.text = "hp : " + str(health) + "\nknife"
   else : 
      var currentWeapon = weapons[currentWeaponName]
      UiStatusLabel.text = "hp : " + str(health) + "\nammo : " + str(currentWeapon.ammoInWeapon) + " / " + str(currentWeapon.ammoSpare)


# 9. instance the simple audio player 
func createSound(soundName, position = null) :
   var audioClone = simpleAudioPlayer.instance()
   var sceneRoot  = get_tree().root.get_children()[0]
   
   sceneRoot.add_child(audioClone)
   audioClone.playSound(soundName, position)
   

# 10. process input data from external joypads 
# FIX - : controller support and axis movement to be fixed   
func processInputView(_delta) :
   if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED :
      return   
   
   # NOTE - : until some bugs relating to captured mice are fixed, we cannot put the mouse view
   # rotation code here. Once the bug(s) are fixed, code for mouse view rotation code will go here
   # src: https://docs.godotengine.org/en/3.2/tutorials/3d/fps_tutorial/part_four.html
   
   # JOYPAD : rotation
   var joyPadVector = Vector2()
   if Input.get_connected_joypads().size() > 0 :
      
      if OS.get_name() == "Windows" :
         joyPadVector = Vector2(Input.get_joy_axis(0, 2), Input.get_joy_axis(0,3))
      elif OS.get_name() == "X11" :
         joyPadVector = Vector2(Input.get_joy_axis(0, 3), Input.get_joy_axis(0, 4))
      elif OS.get_name() == "OSX" :
         joyPadVector = Vector2(Input.get_joy_axis(0, 3), Input.get_joy_axis(0, 4))
      
      if joyPadVector.length() < joyPadDeadZone :
         joyPadVector = Vector2(0, 0)
      else : 
         joyPadVector = joyPadVector.normalized() * ((joyPadVector.length() - joyPadDeadZone) / (1 - joyPadDeadZone))
      
      rotationHelper.rotate_x(deg2rad(joyPadVector.y * joyPadSensitivity))
      
      rotate_y(deg2rad(joyPadVector.x * joyPadSensitivity * -1))
      
      var cameraRotation = rotationHelper.rotation_degrees
      cameraRotation.x = clamp(cameraRotation.x, -70, 70)
      rotationHelper.rotation_degrees = cameraRotation
   
# 11. add health 
func addHealth(additionalHealth) :
   health += additionalHealth
   health = clamp(health, 0, maxHealth)
   

# 12. add ammo
func addAmmo(additionalAmmo) :
   if (currentWeaponName != "unarmed") :
      if (weapons[currentWeaponName].canRefill == true) :
         weapons[currentWeaponName].ammoSpare += weapons[currentWeaponName].ammoInMag * additionalAmmo
   # to limit ammo amount add variable to each weapon's script
   # clamp the weapon's ammoSpare after adding ammo

   
