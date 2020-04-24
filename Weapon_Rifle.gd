extends Spatial

# MARKUP - : Properties
const ammoInMag   = 50
const canReload   = true
const canRefill   = true
const damage      = 50
const fireAnimationName       = "Rifle_fire"
const idleAnimationName       = "Rifle_idle"
const reloadingAnimationName  = "Rifle_reload"

var ammoInWeapon        = 100
var ammoSpare           = 100
var isWeaponEnabled     = false
var playerNode          = null


# MARKUP - : Ready
func _ready() :
   pass

# MARKUP - : Functions
func fireWeapon() :
   var ray = $Ray_Cast
   ray.force_raycast_update()
   
   if ray.is_colliding():
      var body = ray.get_collider()
      
      if body == playerNode :
         pass
      elif body.has_method("bulletHit") :
         body.bulletHit(damage, ray.global_transform)
   
   ammoInWeapon -= 1
   playerNode.createSound("RifleShot", ray.global_transform.origin)
   
func equipWeapon() : 
   if playerNode.animationManager.currentState == idleAnimationName :
      isWeaponEnabled = true
      return true
      
   if playerNode.animationManager.currentState == "Idle_unarmed" : 
      playerNode.animationManager.setAnimation ("Rifle_equip")
      
   return false 

func unequipWeapon() :
   if playerNode.animationManager.currentState == idleAnimationName :
      if playerNode.animationManager.currentState != "Rifle_unequip" :
         playerNode.animationManager.setAnimation("Rifle_unequip")
      
   if playerNode.animationManager.currentState == "Idle_unarmed" :
      isWeaponEnabled = false
      return true
      
   return false
   
func reloadWeapon() : 
   var canReload = false
   
   if playerNode.animationManager.currentState == idleAnimationName :
      canReload = true
      
   if ammoSpare <= 0 or ammoInWeapon == ammoInMag :
      canReload = true
   
   if canReload == true : 
      var ammoNeeded = ammoInMag - ammoInWeapon
      
      if ammoSpare >= ammoNeeded :
         ammoSpare -= ammoNeeded
         ammoInWeapon = ammoInMag
      else : 
         ammoInWeapon += ammoSpare
         ammoSpare = 0
      
      playerNode.animationManager.setAnimation(reloadingAnimationName)
      playerNode.createSound("GunCock", playerNode.camera.global_transform.origin)
      
      return true
      
   return false

