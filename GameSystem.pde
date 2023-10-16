final class GameSystem
{
  final ActorGroup myGroup, otherGroup;
  final ParticleSet commonParticleSet;
  GameSystemState currentState;
  float screenShakeValue;
  final DamagedPlayerActorState damagedState;
  final GameBackground currentBackground;
  final boolean demoPlay;
  boolean showsInstructionWindow;

  GameSystem(boolean demo, boolean instruction) {
    // prepare ActorGroup
    myGroup = new ActorGroup();
    otherGroup = new ActorGroup();
    myGroup.enemyGroup = otherGroup;
    otherGroup.enemyGroup = myGroup;

    // prepare PlayerActorState
    final MovePlayerActorState moveState = new MovePlayerActorState();
    final DrawBowPlayerActorState drawShortbowState = new DrawShortbowPlayerActorState();
    final DrawBowPlayerActorState drawLongbowState = new DrawLongbowPlayerActorState();
    damagedState = new DamagedPlayerActorState();
    moveState.drawShortbowState = drawShortbowState;
    moveState.drawLongbowState = drawLongbowState;
    drawShortbowState.moveState = moveState;
    drawLongbowState.moveState = moveState;
    damagedState.moveState = moveState;

    // prepare PlayerActor
    PlayerEngine myEngine;
    if (demo) myEngine = new ComputerPlayerEngine();
    else myEngine = new HumanPlayerEngine(currentKeyInput);
    PlayerActor myPlayer = new PlayerActor(myEngine, color(255.0));
    myPlayer.xPosition = INTERNAL_CANVAS_SIDE_LENGTH * 0.5;
    myPlayer.yPosition = INTERNAL_CANVAS_SIDE_LENGTH - 100.0;
    myPlayer.state = moveState;
    myGroup.setPlayer(myPlayer);
    PlayerEngine otherEngine = new ComputerPlayerEngine();
    PlayerActor otherPlayer = new PlayerActor(otherEngine, color(0.0));
    otherPlayer.xPosition = INTERNAL_CANVAS_SIDE_LENGTH * 0.5;
    otherPlayer.yPosition = 100.0;
    otherPlayer.state = moveState;
    otherGroup.setPlayer(otherPlayer);

    // other
    commonParticleSet = new ParticleSet(2048);
    currentState = new StartGameState();
    currentBackground = new GameBackground(color(224.0), 0.1);
    demoPlay = demo;
    showsInstructionWindow = instruction;
  }
  GameSystem() {
    this(false, false);
  }

  void run() {
    if (demoPlay) {
      if (currentKeyInput.isZPressed) {
        system = new GameSystem();  // stop demo and start game
        return;
      }
    }
    
    pushMatrix();
    
    if (screenShakeValue > 0.0) {
      translate(random(-screenShakeValue, screenShakeValue), random(-screenShakeValue, screenShakeValue));
      screenShakeValue -= 50.0 / FPS;
    }
    currentBackground.update();
    currentBackground.display();
    currentState.run(this);
    
    popMatrix();
    if (demoPlay && showsInstructionWindow) displayDemo();
  }
  
  void displayDemo() {
    pushStyle();

    stroke(0.0);
    strokeWeight(2.0);
    fill(255.0, 240.0);
    rect(
      INTERNAL_CANVAS_SIDE_LENGTH * 0.5,
      INTERNAL_CANVAS_SIDE_LENGTH * 0.5,
      INTERNAL_CANVAS_SIDE_LENGTH * 0.7,
      INTERNAL_CANVAS_SIDE_LENGTH * 0.6
    );

    textFont(smallFont, 20.0);
    textLeading(26.0);
    textAlign(RIGHT, BASELINE);
    fill(0.0);
    text("Z key:", 280.0, 180.0);
    text("X key:", 280.0, 250.0);
    text("Arrow key:", 280.0, 345.0);
    textAlign(LEFT);
    text("Weak shot\n (auto aiming)", 300.0, 180.0);
    text("Lethal shot\n (manual aiming,\n  requires charge)", 300.0, 250.0);
    text("Move\n (or aim lethal shot)", 300.0, 345.0);
    textAlign(CENTER);
    text("- Press Z key to start -", INTERNAL_CANVAS_SIDE_LENGTH * 0.5, 430.0);
    text("(Click to hide this window)", INTERNAL_CANVAS_SIDE_LENGTH * 0.5, 475.0);
    popStyle();
    
    strokeWeight(1.0);
  }

  void addSquareParticles(float x, float y, int particleCount, float particleSize, float minSpeed, float maxSpeed, float lifespanSecondValue) {
    final ParticleBuilder builder = system.commonParticleSet
                                          .builder
                                          .type(1)  // Square  
                                          .position(x, y)
                                          .particleSize(particleSize)
                                          .particleColor(color(0.0))
                                          .lifespanSecond(lifespanSecondValue);
    for (int i = 0; i < particleCount; i++) {
      final Particle newParticle = builder
        .polarVelocity(random(TWO_PI), random(minSpeed, maxSpeed))
        .build();
      system.commonParticleSet.particleList.add(newParticle);
    }
  }
}

final class GameBackground
{
  final ArrayList<BackgroundLine> lineList = new ArrayList<BackgroundLine>();
  final float maxAccelerationMagnitude;
  final color lineColor;

  GameBackground(color col, float maxAcc) {
    lineColor = col;
    maxAccelerationMagnitude = maxAcc;
    for (int i = 0; i < 10; i++) {
      lineList.add(new HorizontalLine());
    }
    for (int i = 0; i < 10; i++) {
      lineList.add(new VerticalLine());
    }
  }

  void update() {
    for (BackgroundLine eachLine : lineList) {
      eachLine.update(random(-maxAccelerationMagnitude, maxAccelerationMagnitude));
    }
  }
  void display() {
    stroke(lineColor);
    for (BackgroundLine eachLine : lineList) {
      eachLine.display();
    }
  }
}
abstract class BackgroundLine
{
  float position;
  float velocity;

  BackgroundLine(float initialPosition) {
    position = initialPosition;
  }
  void update(float acceleration) {
    position += velocity;
    velocity += acceleration;
    if (position < 0.0 || position > getMaxPosition()) velocity = -velocity;
  }
  abstract void display();
  abstract float getMaxPosition();
}
final class HorizontalLine
  extends BackgroundLine
{
  HorizontalLine() {
    super(random(INTERNAL_CANVAS_SIDE_LENGTH));
  }
  void display() {
    line(0.0, position, INTERNAL_CANVAS_SIDE_LENGTH, position);
  }
  float getMaxPosition() {
    return INTERNAL_CANVAS_SIDE_LENGTH;
  }
}
final class VerticalLine
  extends BackgroundLine
{
  VerticalLine() {
    super(random(INTERNAL_CANVAS_SIDE_LENGTH));
  }
  void display() {
    line(position, 0.0, position, INTERNAL_CANVAS_SIDE_LENGTH);
  }
  float getMaxPosition() {
    return INTERNAL_CANVAS_SIDE_LENGTH;
  }
}

final class ActorGroup
{
  ActorGroup enemyGroup;

  AbstractPlayerActor player;
  final ArrayList<AbstractArrowActor> arrowList = new ArrayList<AbstractArrowActor>();
  final ArrayList<AbstractArrowActor> removingArrowList = new ArrayList<AbstractArrowActor>();

  void update() {
    player.update();

    if (removingArrowList.size() >= 1) {
      arrowList.removeAll(removingArrowList);
      removingArrowList.clear();
    }

    for (AbstractArrowActor eachArrow : arrowList) {
      eachArrow.update();
    }
  }
  void act() {
    player.act();
    for (AbstractArrowActor eachArrow : arrowList) {
      eachArrow.act();
    }
  }

  void setPlayer(PlayerActor newPlayer) {
    player = newPlayer;
    newPlayer.group = this;
  }
  void addArrow(AbstractArrowActor newArrow) {
    arrowList.add(newArrow);
    newArrow.group = this;
  }

  void displayPlayer() {
    player.display();
  }
  void displayArrows() {
    for (AbstractArrowActor eachArrow : arrowList) {
      eachArrow.display();
    }
  }
}
