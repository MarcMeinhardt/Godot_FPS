extends RigidBody

const baseBulletBoost = 12;

func ready() :
   pass
   
func bulletHit(damage, bulletGlobalTrans) :
   var directionVector = bulletGlobalTrans.basis.z.normalized() * baseBulletBoost;
   
   apply_impulse((bulletGlobalTrans.origin - global_transform.origin).normalized(), directionVector * damage)
   

