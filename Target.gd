# 15/04/2020 keep it up !

extends StaticBody

# MARKUP - : Properties
const targetHealth   = 5
var brokenTargetHolder
var currentHealth    = 5
var targetCollisionShape 
# NOTE - : currentHealth used to hold the brokenTarget holder node
# NOTE - : targetCollisionShape is for the whole target, not the broken target

# VARIABLES : for target respawn
const targetRespawnTime = 5
var targetRespawnTimer  = 0 

export (PackedScene) var destroyedTarget
# a packed scene to hold the BrokenTarget scene
# a simplified interface to a scene file. 
# provides access to operations and checks that can be performed on the scene resource itself.


# MARKUP - : Ready
func _ready():
   brokenTargetHolder = get_parent().get_node("Broken_Target_Holder")
#   brokenTargetHolder = $"../Broken_Target_Holder"
   targetCollisionShape = $Collision_Shape
   
   
# MARKUP - : Functions
func _physics_process(delta):
   if targetRespawnTimer > 0 :
      targetRespawnTimer -= delta
      
      if targetRespawnTimer <= 0 : 
         for child in brokenTargetHolder.get_children() :
            child.queue_free()
            
         targetCollisionShape.disabled = false
         visible = true
         currentHealth = targetHealth
   
func bulletHit(damage, bulletHitPos) :
   currentHealth -= damage
   
   if currentHealth <= 0 :
      var clone = destroyedTarget.instance()
      brokenTargetHolder.add_child(clone)

      for rigid in clone.get_children() :
         if rigid is RigidBody :
            var centerInRigidSpace = brokenTargetHolder.global_transform.origin - rigid.global_transform.origin
            var direction = (rigid.transform.origin - centerInRigidSpace).normalized()
            rigid.apply_impulse(centerInRigidSpace, direction * 12 * damage)
            # apply the impulse with additional force (12)

      targetRespawnTimer = targetRespawnTime
      
      #targetCollisionShape.disabled = false
      visible = false
         
            
            
   
   
   

