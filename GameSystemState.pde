abstract class GameSystemState
{
  int properFrameCount;

  void run(GameSystem system) {
    runSystem(system);

    translate(INTERNAL_CANVAS_SIDE_LENGTH * 0.5, INTERNAL_CANVAS_SIDE_LENGTH * 0.5);
    displayMessage(system);

    checkStateTransition(system);

    properFrameCount++;
  }
  abstract void runSystem(GameSystem system);
  abstract void displayMessage(GameSystem system);
  abstract void checkStateTransition(GameSystem system);
}

final class StartGameState
  extends GameSystemState
{
  final int frameCountPerNumber = int(FPS);
  final float ringSize = 200.0;
  final color ringColor = color(0.0);
  final float ringStrokeWeight = 5.0;
  int displayNumber = 4;

  void runSystem(GameSystem system) {
    system.myGroup.update();
    system.otherGroup.update();
    system.myGroup.displayPlayer();
    system.otherGroup.displayPlayer();
  }

  void displayMessage(GameSystem system) {
    final int currentNumberFrameCount = properFrameCount % frameCountPerNumber;
    if (currentNumberFrameCount == 0) displayNumber--;
    if (displayNumber <= 0) return;

    fill(ringColor);
    text(displayNumber, 0.0, 0.0);

    rotate(-HALF_PI);
    strokeWeight(3.0);
    stroke(ringColor);
    noFill();
    arc(0.0, 0.0, ringSize, ringSize, 0.0, TWO_PI * float(properFrameCount % frameCountPerNumber) / frameCountPerNumber);
    strokeWeight(1.0);
  }

  void checkStateTransition(GameSystem system) {
    if (properFrameCount >= frameCountPerNumber * 3) {
      final Particle newParticle = system.commonParticleSet.builder
        .type(3)  // Ring
        .position(INTERNAL_CANVAS_SIDE_LENGTH * 0.5, INTERNAL_CANVAS_SIDE_LENGTH * 0.5)
        .polarVelocity(0.0, 0.0)
        .particleSize(ringSize)
        .particleColor(ringColor)
        .weight(ringStrokeWeight)
        .lifespanSecond(1.0)
        .build();
      system.commonParticleSet.particleList.add(newParticle);

      system.currentState = new PlayGameState();
    }
  }
}

final class PlayGameState
  extends GameSystemState
{
  int messageDurationFrameCount = int(FPS);

  void runSystem(GameSystem system) {
    system.myGroup.update();
    system.myGroup.act();
    system.otherGroup.update();
    system.otherGroup.act();
    system.myGroup.displayPlayer();
    system.otherGroup.displayPlayer();
    system.myGroup.displayArrows();
    system.otherGroup.displayArrows();

    checkCollision();

    system.commonParticleSet.update();
    system.commonParticleSet.display();
  }

  void displayMessage(GameSystem system) {
    if (properFrameCount >= messageDurationFrameCount) return;
    fill(0.0, 255.0 * (1.0 - float(properFrameCount) / messageDurationFrameCount));
    text("Go", 0.0, 0.0);
  }

  void checkStateTransition(GameSystem system) {
    if (system.myGroup.player.isNull()) {
      system.currentState = new GameResultState("You lose.");
    } else if (system.otherGroup.player.isNull()) {
      system.currentState = new GameResultState("You win.");
    }
  }  

  void checkCollision() {
    final ActorGroup myGroup = system.myGroup;
    final ActorGroup otherGroup = system.otherGroup;

    for (AbstractArrowActor eachMyArrow : myGroup.arrowList) {
      for (AbstractArrowActor eachEnemyArrow : otherGroup.arrowList) {
        if (eachMyArrow.isCollided(eachEnemyArrow) == false) continue;
        breakArrow(eachMyArrow, myGroup);
        breakArrow(eachEnemyArrow, otherGroup);
      }
    }

    if (otherGroup.player.isNull() == false) {
      for (AbstractArrowActor eachMyArrow : myGroup.arrowList) {

        AbstractPlayerActor enemyPlayer = otherGroup.player;
        if (eachMyArrow.isCollided(enemyPlayer) == false) continue;

        if (eachMyArrow.isLethal()) killPlayer(otherGroup.player);
        else thrustPlayerActor(eachMyArrow, (PlayerActor)enemyPlayer);

        breakArrow(eachMyArrow, myGroup);
      }
    }

    if (myGroup.player.isNull() == false) {
      for ( AbstractArrowActor eachEnemyArrow : otherGroup.arrowList) {
        if (eachEnemyArrow.isCollided(myGroup.player) == false) continue;

        if (eachEnemyArrow.isLethal()) killPlayer(myGroup.player);
        else thrustPlayerActor(eachEnemyArrow, (PlayerActor)myGroup.player);

        breakArrow(eachEnemyArrow, otherGroup);
      }
    }
  }

  void killPlayer(AbstractPlayerActor player) {
    system.addSquareParticles(player.xPosition, player.yPosition, 50, 16.0, 2.0, 10.0, 4.0);
    player.group.player = new NullPlayerActor();
    system.screenShakeValue = 50.0;
  }

  void breakArrow(AbstractArrowActor arrow, ActorGroup group) {
    system.addSquareParticles(arrow.xPosition, arrow.yPosition, 10, 7.0, 1.0, 5.0, 1.0);
    group.removingArrowList.add(arrow);
  }

  void thrustPlayerActor(Actor referenceActor, PlayerActor targetPlayerActor) {
    final float relativeAngle = atan2(targetPlayerActor.yPosition - referenceActor.yPosition, targetPlayerActor.xPosition - referenceActor.xPosition);
    final float thrustAngle = relativeAngle + random(-0.5 * HALF_PI, 0.5 * HALF_PI);
    targetPlayerActor.xVelocity += 20.0 * cos(thrustAngle);
    targetPlayerActor.yVelocity += 20.0 * sin(thrustAngle);
    targetPlayerActor.state = system.damagedState.entryState(targetPlayerActor);
    system.screenShakeValue += 10.0;
  }
}

final class GameResultState
  extends GameSystemState
{
  final String resultMessage;
  final int durationFrameCount = int(FPS);

  GameResultState(String msg) {
    resultMessage = msg;
  }

  void runSystem(GameSystem system) {
    system.myGroup.update();
    system.otherGroup.update();
    system.myGroup.displayPlayer();
    system.otherGroup.displayPlayer();

    system.commonParticleSet.update();
    system.commonParticleSet.display();
  }

  void displayMessage(GameSystem system) {
    if (system.demoPlay) return;

    fill(0.0);
    text(resultMessage, 0.0, 0.0);
    if (properFrameCount > durationFrameCount) {
      pushStyle();
      textFont(smallFont, 20.0);
      text("Press X key to reset.", 0.0, 80.0);
      popStyle();
    }
  }

  void checkStateTransition(GameSystem system) {
    if (system.demoPlay) {
      if (properFrameCount > durationFrameCount * 3) {
        newGame(true, system.showsInstructionWindow);
      }
    } else {
      if (properFrameCount > durationFrameCount && currentKeyInput.isXPressed) {
        newGame(true, true);  // back to demoplay with instruction window
      }
    }
  }
}
