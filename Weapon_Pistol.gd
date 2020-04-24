extends Spatial

# MARKUP - : Properties
const ammoInMag   = 10
const canReload   = true
const canRefill   = true
const damage      = 25
const fireAnimationName       = "Pistol_fire"
const idleAnimationName       = "Pistol_idle"
const reloadingAnimationName  = "Pistol_reload"

var ammoInWeapon     = 10
var ammoSpare        = 20 
var bulletScene      = preload("Bullet_Scene.tscn")
var isWeaponEnabled  = false
var playerNode       = null 


# MARKUP - : Ready 
func _ready():
   pass   
   
   
# MARKUP - : Functions
func fireWeapon() : 
   var clone = bulletScene.instance()
   var sceneRoot = get_tree().root.get_children()[0]
   sceneRoot.add_child(clone)
   
   clone.global_transform = self.global_transform
   clone.scale = Vector3(4, 4, 4)
   clone.bulletDamage = damage
   ammoInWeapon -= 1
   playerNode.createSound("PistolShot", self.global_transform.origin)
   
func equipWeapon() : 
   if playerNode.animationManager.currentState == idleAnimationName:
      isWeaponEnabled = true 
      return true

   if playerNode.animationManager.currentState == "Idle_unarmed":
      playerNode.animationManager.setAnimation("Pistol_equip")
      
   return false
   
func unequipWeapon() :
   if playerNode.animationManager.currentState == idleAnimationName :
      if playerNode.animationManager.currentState != "Pistol_unequip":
         playerNode.animationManager.setAnimation("Pistol_unequip")
   
   if playerNode.animationManager.currentState == "Idle_unarmed" :
      isWeaponEnabled = false
      return true
   else :
      return false
      
func reloadWeapon() :
   var canReload = false
   
   if playerNode.animationManager.currentState == idleAnimationName :
      canReload = true
      
   if ammoSpare <= 0 or ammoInWeapon == ammoInMag :
      canReload = false
      
   if ammoSpare <= 0 or ammoInWeapon == ammoInMag :
      canReload = false 
      
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
         
      
      
      
      
   
   
      
      
   
