final class ParticleSet
{
  final ArrayList<Particle> particleList;
  final ArrayList<Particle> removingParticleList;
  final ObjectPool<Particle> particlePool;
  final ParticleBuilder builder;

  ParticleSet(int capacity) {
    particlePool = new ObjectPool<Particle>(capacity);
    for (int i = 0; i < capacity; i++) {
      particlePool.pool.add(new Particle());
    }

    particleList = new ArrayList<Particle>(capacity);
    removingParticleList = new ArrayList<Particle>(capacity);
    builder = new ParticleBuilder();
  }

  void update() {
    particlePool.update();

    for (Particle eachParticle : particleList) {
      eachParticle.update();
    }

    if (removingParticleList.size() >= 1) {
      for (Particle eachInstance : removingParticleList) {
        particlePool.deallocate(eachInstance);
      }
      particleList.removeAll(removingParticleList);
      removingParticleList.clear();
    }
  }

  void display() {
    for (Particle eachParticle : particleList) {
      eachParticle.display();
    }
  }

  Particle allocate() {
    return particlePool.allocate();
  }
}

final class ParticleBuilder {
  int particleTypeNumber;

  float xPosition, yPosition;
  float xVelocity, yVelocity;
  float directionAngle, speed;

  float rotationAngle;
  color displayColor;
  float strokeWeightValue;
  float displaySize;

  int lifespanFrameCount;

  ParticleBuilder initialize() {
    particleTypeNumber = 0;
    xPosition = 0.0;
    yPosition = 0.0;
    xVelocity = 0.0;
    yVelocity = 0.0;
    directionAngle = 0.0;
    speed = 0.0;
    rotationAngle = 0.0;
    displayColor = color(0.0);
    strokeWeightValue = 1.0;
    displaySize = 10.0;
    lifespanFrameCount = 60;
    return this;
  }
  ParticleBuilder type(int v) {
    particleTypeNumber = v;
    return this;
  }
  ParticleBuilder position(float x, float y) {
    xPosition = x;
    yPosition = y;
    return this;
  }
  ParticleBuilder polarVelocity(float dir, float spd) {
    directionAngle = dir;
    speed = spd;
    xVelocity = spd * cos(dir);
    yVelocity = spd * sin(dir);
    return this;
  }
  ParticleBuilder rotation(float v) {
    rotationAngle = v;
    return this;
  }
  ParticleBuilder particleColor(color c) {
    displayColor = c;
    return this;
  }
  ParticleBuilder weight(float v) {
    strokeWeightValue = v;
    return this;
  }
  ParticleBuilder particleSize(float v) {
    displaySize = v;
    return this;
  }
  ParticleBuilder lifespan(int v) {
    lifespanFrameCount = v;
    return this;
  }
  ParticleBuilder lifespanSecond(float v) {
    lifespan(int(v * FPS));
    return this;
  }
  Particle build() {
    final Particle newParticle = system.commonParticleSet.allocate();
    newParticle.particleTypeNumber = this.particleTypeNumber;
    newParticle.xPosition = this.xPosition;
    newParticle.yPosition = this.yPosition;
    newParticle.xVelocity = this.xVelocity;
    newParticle.yVelocity = this.yVelocity;
    newParticle.directionAngle = this.directionAngle;
    newParticle.speed = this.speed;
    newParticle.rotationAngle = this.rotationAngle;
    newParticle.displayColor = this.displayColor;
    newParticle.strokeWeightValue = this.strokeWeightValue;
    newParticle.displaySize = this.displaySize;
    newParticle.lifespanFrameCount = this.lifespanFrameCount;
    return newParticle;
  }
}
