//===========================
// GEESE GAME
// Created for Assignment 2B
//===========================


//=================
// Global Variables
//=================

// Window size
final int WINDOW_WIDTH = 1200;
final int WINDOW_HEIGHT = 800;

// Game information area
final int INFO_AREA_WIDTH = 190;
final int INFO_AREA_HEIGHT = 180;

// Movement speed
final int MOVE_SPEED = 4;

// Collision distance
final int COLLISION_DISTANCE = 30;

// Grass height
final int GRASS_HEIGHT = 100;

// Food size
final int FOOD_SIZE = 25;

// Creates the goose object
Goose goose = new Goose(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2, 60);

// Stores the food position on the screen
int foodX = 300;
int foodY = 300;

// Stores the player's current score
int score = 0;

// Stores player's remaining lives
int lives = 3;

// Prevents losing multiple lives from one collision
boolean canLoseLife = true;

// Tracks whether WASD keys are being held down
boolean wPressed = false;
boolean aPressed = false;
boolean sPressed = false;
boolean dPressed = false;

// Number of active fox obstacles in the game
final int MAX_OBSTACLES = 10;
int numberOfObstacles = 0;

// Controls which screen is displayed
int gameState = 0;

// 0 = Start screen

// 1 = Playing game

// 2 = Game over

// 3 = Win screen

// Time limit in seconds
int gameTime = 60;

// Stores when the game started
int startTime;

// Stores the current game level
int level = 1;

// Stores the current movement speed
int currentSpeed = MOVE_SPEED;

// Score needed to increase level
final int LEVEL_UP_SCORE = 2;

// Goose image
PImage gooseImage;

// Bread image
PImage breadImage;

// Fox image 
PImage foxImage;

// Stores fox obstacle objects
Obstacle[] obstacles = new Obstacle[MAX_OBSTACLES];

// Border limit
final int BORDER_LIMIT = 20;

// =========================
// Settings Method
// Sets the game window size
// =========================

void settings()
 {
  size(WINDOW_WIDTH, WINDOW_HEIGHT);
  smooth();
 }
 
//===================================
// SETUP METHOD
// Runs once when the program starts
//===================================

void setup()
{
 // Start the game timer
 startTime = millis();

 // Load the goose image
 gooseImage = loadImage("goose2.png");
 
 // Load the bread image
 breadImage = loadImage("bread.png");
 
 // Load the fox image
 foxImage = loadImage("fox.png");

 // Check image loaded successfully
   if (gooseImage == null)
   {
     println("Goose image could not be loaded!");
     exit();
   }
   
   if (breadImage == null)
   {
     println("Bread image could not be loaded!");
     exit();
   }
   
   if (foxImage == null)
   {
     println("Fox image could not be loaded!");
     exit();
   }

   // Sets image to draw from the centre
   imageMode(CENTER);

 // Resize image using the goose object's size
 gooseImage.resize(goose.size, goose.size);
 breadImage.resize(FOOD_SIZE * 2, FOOD_SIZE * 2);
 foxImage.resize(60, 60);
 
 // Create fox obstacle objects with random positions and speeds
for (int i = 0; i < MAX_OBSTACLES; i++)
 {
   obstacles[i] = new Obstacle(
   int(random(-300, -60)), 
   int(random(INFO_AREA_HEIGHT + 40, WINDOW_HEIGHT - GRASS_HEIGHT - 20)),
   int(random(1, 4))
   );
 }
}

// ========================================
// DRAW METHOD
// This runs repeatedly to update the game 
//=========================================


void draw()
{
  // Allows the player to lose another life after moving away from the reset position
  if (dist(goose.x, goose.y, WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2) > 50)
  {
    canLoseLife = true;
  }

  // Display start screen
  if (gameState == 0)
  {
    startScreen();
  }

  // Display gameplay
  else if (gameState == 1)
  {
    goose.move();
    playGame();
  }

  // Display game over screen
  else if (gameState == 2)
  {
    gameOverScreen();
  }

  // Display win screen
  else if (gameState == 3)
  {
    winScreen();
  }

}

//========================
// Play Game Method
// Runs the main game loop
//========================

void playGame()
{
  background(135,206,235);
  
  // Align game information to the left
  textAlign(LEFT);

  // Draw grass
  fill(50, 180, 50);
  rect(0, WINDOW_HEIGHT - GRASS_HEIGHT, WINDOW_WIDTH, GRASS_HEIGHT);

  // Display the goose image
  image(gooseImage, goose.x, goose.y);

  // Update and display each active fox obstacle
  for (int i = 0; i < numberOfObstacles; i++)
  {
    obstacles[i].move();
    obstacles[i].display();
  }
 
  // Display the bread image
  image(breadImage, foodX, foodY);

  // Draw a background behind the game information
  fill(255);
  rect(10, 10, INFO_AREA_WIDTH, INFO_AREA_HEIGHT);

  // Display the player's score, level, timer and remaining lives
  fill(0);
  textSize(20);
  text("Score: " + score, 30, 40);
  text("Level: " + level, 30, 80);
  int timeLeft = gameTime - int((millis()-startTime)/1000);
  text("Time: " + timeLeft, 30, 120);
  text("Lives: " + lives, 30, 160);

  if (timeLeft <= 0 || lives <= 0)
  {
    gameState = 2;
  }

// =====================================
// Check if the goose collects the bread
// =====================================

if (dist(goose.x, goose.y, foodX, foodY) < COLLISION_DISTANCE)

{

  // Increase score 
  score++;
  
  // Level up 
  if (score % LEVEL_UP_SCORE == 0)
  {
    level++;
    
    // Add one fox obstacle every level
    if (numberOfObstacles < MAX_OBSTACLES)
    {
      numberOfObstacles++;
    }
    
    // Increase fox speed every two levels
    if (level % 2 == 0)
    {
      for (int i = 0; i < numberOfObstacles; i++)
      {
        if (obstacles[i].speed < 6)
        {
        obstacles[i].speed++;
      } 
    } 
  }
} 

  // Win condition
  if (level >= 10)
  {
    gameState = 3;
  }

  // Move bread to a new position
  foodX = int(random(INFO_AREA_WIDTH + 40, WINDOW_WIDTH - COLLISION_DISTANCE));
  foodY = int(random(INFO_AREA_HEIGHT + 40, WINDOW_HEIGHT - GRASS_HEIGHT - 20));

}

// ==================================================
// Check for collision between the goose and each fox
// ==================================================

for (int i = 0; i < numberOfObstacles; i++)
{
  // Lose one life if the goose touches a fox
  if (dist(goose.x, goose.y, obstacles[i].x, obstacles[i].y) < COLLISION_DISTANCE)
  {
    if (canLoseLife)
    {
      lives--;

      canLoseLife = false;

      goose.x = WINDOW_WIDTH / 2;
      goose.y = WINDOW_HEIGHT / 2;
    }
  }
}

} // END OF playGame()

 
// ==============================================
// Allows the player to move the goose using WASD
// ==============================================

void keyPressed()
{
  // Records which WASD key is being held down

  if (key == 'w' || key == 'W')
  {
    wPressed = true;
  }

  if (key == 's' || key == 'S')
  {
    sPressed = true;
  }

  if (key == 'a' || key == 'A')
  {
    aPressed = true;
  }

  if (key == 'd' || key == 'D')
  {
    dPressed = true;
  }
  
 // Restart game
 if (key == 'r' || key == 'R')
 {
   // Reset game values
   score = 0;
   lives = 3;
   level = 1;

   currentSpeed = MOVE_SPEED;
   numberOfObstacles = 0;
   canLoseLife = true;
  
   // Reset obstacle speeds 
   for (int i = 0; i < MAX_OBSTACLES; i++)
   {
    obstacles[i].speed = int(random(1, 4));
   }
  
   // Reset movement keys
   wPressed = false;
   aPressed = false;
   sPressed = false;
   dPressed = false;

   // Return to start screen
   gameState = 0;   
   startTime = millis();

   goose.x = WINDOW_WIDTH / 2;
   goose.y = WINDOW_HEIGHT / 2;
}

 // Start game with SPACE
 if (key == ' ')
 {
  gameState = 1;   
  startTime = millis();
 }
}

//===========================================
// Stops movement when a WASD key is released
//===========================================

void keyReleased()
{
  if (key == 'w' || key == 'W')
  {
    wPressed = false;
  }
  
  if (key == 's' || key == 'S')
  {
    sPressed = false;
  }
  
  if (key == 'a' || key == 'A')
  {
    aPressed = false;
  }
  
  if (key == 'd' || key == 'D')
  {
    dPressed = false;
  }
}

// ====================
// Draw Game Background
// ====================

void drawBackground()
{
  // Sky
  background(135, 206, 235);
  
  // Grass
  fill(50, 180, 50);
  rect(0, WINDOW_HEIGHT - GRASS_HEIGHT, WINDOW_WIDTH, GRASS_HEIGHT);
}

// ============
// Start screen
// ============

void startScreen()

{
  drawBackground();
  
  // Draw panel behind instructions
  fill(255, 240);
  rect(WINDOW_WIDTH / 2 - 250, 80, 500, 460, 20);
  
  // Draw goose image
  image(gooseImage, WINDOW_WIDTH / 2, 145, 80, 80);
  
  // Draw text
  fill(0);
  textAlign(CENTER);
  
  // Game title
  textSize(40);
  text("GEESE GAME", WINDOW_WIDTH / 2, 225);
  
  // Instructions
  textSize(20);
  text("Use WASD to move", WINDOW_WIDTH / 2, 305);
  text("Collect the bread", WINDOW_WIDTH / 2, 345);
  text("Avoid the foxes", WINDOW_WIDTH / 2, 385);
  
  // Start instruction
  textSize(25);
  text("Press SPACE to start", WINDOW_WIDTH / 2, 475);
}

// =================
// Game Over Screen
// =================

void gameOverScreen()
{
  drawBackground();
  
  // Draw panel behind game over information
  fill(255, 240);
  rect(WINDOW_WIDTH / 2 - 220, 180, 440, 340, 20);
  
  // Draw fox image
  image(foxImage, WINDOW_WIDTH / 2, 255, 70, 70);
  
  // Draw text
  fill(0);
  textAlign(CENTER);
  
  // Game over title
  textSize(50);
  text("GAME OVER", WINDOW_WIDTH / 2, 335);
  
  // Final score 
  textSize(25);
  text("Final Score: " + score, WINDOW_WIDTH / 2, 395);
  
  // Restart instructions
  text("Press R to restart", WINDOW_WIDTH / 2,  440);
}

// ===========
// Win Screen
// ===========

void winScreen()

{
  drawBackground();
  
  // Draw panel behind win information
  fill(255, 240);
  rect(WINDOW_WIDTH / 2 - 220, 180, 440, 340, 20);
  
  // Draw goose image
  image(gooseImage, WINDOW_WIDTH / 2, 255, 70, 70);
  
  // Draw text
  fill(0);
  textAlign(CENTER);
  
  // title
  textSize(50);
  text("YOU WIN!", WINDOW_WIDTH / 2, 335);
  
  //Score
  textSize(25);
  text("Final Score: " + score, WINDOW_WIDTH / 2, 395);
  
  // Restart
  text("Press R to restart", WINDOW_WIDTH / 2, 440);
}

//============
// Goose Class
//============

class Goose 
{
  int x;
  int y;
  int size;
  
  // Creates a new goose object with its starting position and size
  Goose(int x, int y, int size)
  {
    this.x = x;
    this.y = y;
    this.size = size;
  }
  
  // Moves the goose using the WASD keys
  void move()
  {
    if (wPressed && y > BORDER_LIMIT)
    {
      y -= currentSpeed;
    }
    
    if (sPressed && y < WINDOW_HEIGHT - BORDER_LIMIT)
    {
      y += currentSpeed;
    }
    
    if (aPressed && x > BORDER_LIMIT)
    {
      x -= currentSpeed;
    }
    
    if (dPressed && x < WINDOW_WIDTH - BORDER_LIMIT)
    {
      x += currentSpeed;
    }
  } 
}  

//===============
// Obstacle Class
//===============

class Obstacle
{
  int x;
  int y;
  int speed;
  
  // Creates a new fox obstacle with a starting position and speed
  Obstacle(int x, int y, int speed)
  {
    this.x = x;
    this.y = y;
    this.speed = speed;
  }
  
  // Moves the fox obstacle across the screen
  void move()
  {
    x += speed;
    if (x > WINDOW_WIDTH)
    {
      // Restart the fox just off the left side of the screen
      x = -60;
      
      // Keep the fox below the score panel
      y = int(random(INFO_AREA_HEIGHT + 40, WINDOW_HEIGHT - GRASS_HEIGHT - 20));
    }
  }
  
  // Draws the fox obstacle
  void display()
  {
    image(foxImage, x, y);
  }
}
