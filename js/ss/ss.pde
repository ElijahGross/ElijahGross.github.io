int birdX, birdY, birdDiameter;
float birdVelocity;
boolean gameOver = false;
boolean gameWon = false;  // Add a variable to track if the game is won
float gravity = 0.5;
float flapStrength = -12;
int score = 0;
int bestScore = 0;  // Variable to store the best score

ArrayList<Pipe> pipes = new ArrayList<Pipe>();

// Button variables
Button restartButton;
PImage airplane, cloud1, cloud2, cloud3, cloud4, cloud5, bg, pipeT, pipeB, winImage; // Add win image
int bgx, cloudX1, cloudX2;


// Cloud positions, speeds, and images
int[] cloudX = new int[5];
int[] cloudY = new int[5];  // Store Y positions of clouds
int[] cloudSpeeds = new int[5];
PImage[] clouds = new PImage[5];  // Array to store the different cloud images

void setup() {
  size(800, 600); // Window size
  birdX = width / 10;
  birdY = height / 2;
  birdDiameter = 30;
  birdVelocity = 0;

  // Load images
  airplane = loadImage("airplane.png");  // The image of the airplane
  cloud1 = loadImage("cloud1.png");      // First cloud image
  cloud2 = loadImage("cloud2.png");      // Second cloud image
  cloud3 = loadImage("cloud3.png");      // Third cloud image
  cloud4 = loadImage("cloud4.png");      // Fourth cloud image
  cloud5 = loadImage("cloud5.png");      // Fifth cloud image
  bg = loadImage("bg.png");              // Sky background image
  pipeT = loadImage("pipeTop.png");      // Top pipe (Mario style)
  pipeB = loadImage("pipeBottom.png");   // Bottom pipe (Mario style)
  winImage = loadImage("winImage.png");  // Load the win image (replace with actual image path)

  // Store the clouds in the array
  clouds[0] = cloud1;
  clouds[1] = cloud2;
  clouds[2] = cloud3;
  clouds[3] = cloud4;
  clouds[4] = cloud5;

  // Create initial pipes
  pipes.add(new Pipe(width, random(150, height - 150), 80));

  // Create restart button
  restartButton = new Button(width / 2 - 100, height / 2 + 80, 200, 50, "Restart");

  // Initialize cloud positions and speeds
  for (int i = 0; i < 5; i++) {
    cloudX[i] = width + i * 150;  // Spread the clouds across the screen
    cloudY[i] = (int) random(50, height - 150);  // Random Y position for each cloud
    cloudSpeeds[i] = 1 + (int) random(1, 3); // Random speed for each cloud
  }
}

void draw() {
  background(0);  // Clear the screen

  // Draw the background image (bg.png)
  image(bg, 0, 0, width, height);  // Draw the background across the entire window

  // Draw moving clouds
  drawClouds();

  if (gameOver) {
    textSize(32);
    fill(255, 0, 0);
    text("Game Over!", width / 2 - 100, height / 2);
    textSize(24);
    text("Your Score: " + score, width / 2 - 50, height / 2 + 40);
    
    // Update best score if the current score is higher
    if (score > bestScore) {
      bestScore = score;
    }
    
    // Display the best score
    text("Best Score: " + bestScore, width / 2 - 70, height / 2 + 70);
    
    // Draw the restart button
    restartButton.display();
    return;
  }

  if (gameWon) {
    // Draw the win screen
    image(winImage, 0, 0, width, height);  // Display win screen image (full screen)
    textSize(32);
    fill(0, 255, 0);
    text("You Win!", width / 2 - 100, height / 2);
    textSize(24);
    text("Your Score: " + score, width / 2 - 50, height / 2 + 40);
    text("Best Score: " + bestScore, width / 2 - 70, height / 2 + 70);
    return;
  }

  // Apply gravity to bird
  birdVelocity += gravity;
  birdY += birdVelocity;

  // Prevent bird from going out of bounds vertically
  if (birdY + birdDiameter / 2 >= height) {
    birdY = height - birdDiameter / 2;  // Stop at the floor, but don't end the game
  } else if (birdY - birdDiameter / 2 <= 0) {
    birdY = birdDiameter / 2;
    birdVelocity = 0;
  }

  // Draw airplane
  image(airplane, birdX - 30, birdY - 20, 60, 40);  // Adjust position and size of airplane image

  // Update and draw pipes
  for (int i = pipes.size() - 1; i >= 0; i--) {
    Pipe p = pipes.get(i);
    p.update();
    p.display();

    // Check for collision with pipes
    if (p.collidesWithBird(birdX, birdY, birdDiameter / 2)) {
      gameOver = true;
    }
    
    // Check if bird passes the pipe and increase score
    if (p.x + p.width < birdX && !p.passed) {
      score++;
      p.passed = true;
    }

    // Remove pipes that are off the screen
    if (p.x + p.width < 0) {
      pipes.remove(i);
    }
  }

  // Add new pipes if needed
  if (pipes.get(pipes.size() - 1).x <= width - 300) {
    pipes.add(new Pipe(width, random(150, height - 150), 80));
  }

  // Check if score reaches 10 to win
  if (score >= 10) {
    gameWon = true;
  }

  // Display the current score while playing
  textSize(24);
  fill(0);
  text("Score: " + score, 10, 30);
}

void mousePressed() {
  // If mouse is clicked above the bird, make the bird go up
  if (mouseY < birdY) {
    birdVelocity = flapStrength;  // Move bird upwards
  }
  
  // Restart game if button clicked
  if ((gameOver || gameWon) && restartButton.isPressed(mouseX, mouseY)) {
    resetGame();
  }
}

void resetGame() {
  birdY = height / 2;
  birdVelocity = 0;
  score = 0;
  pipes.clear();
  pipes.add(new Pipe(width, random(150, height - 150), 80));
  gameOver = false;
  gameWon = false;
}

// Function to draw moving clouds
void drawClouds() {
  for (int i = 0; i < 5; i++) {
    // Randomly select one of the five cloud images to display
    PImage currentCloud = clouds[(int)random(0, 5)];
    image(currentCloud, cloudX[i], cloudY[i], 150, 100);  // Draw each cloud with a random image
    cloudX[i] -= cloudSpeeds[i];  // Move each cloud left by its speed

    // Reset cloud position when it moves off-screen
    if (cloudX[i] + 150 < 0) {
      cloudX[i] = width;
      cloudY[i] = (int) random(50, height - 150);  // Re-randomize Y position when cloud resets
    }
  }
}

class Pipe {
  float x, topHeight, bottomHeight;
  int width;
  boolean passed = false;

  Pipe(float startX, float topHeight, int width) {
    this.x = startX;
    this.topHeight = topHeight;
    this.width = width;
    this.bottomHeight = height - topHeight - 200;  // Fixed gap size between pipes
  }

  void update() {
    x -= 5;  // Move the pipe leftward
  }

  void display() {
    // Draw pipes like Mario-style pipes (using images)
    image(pipeT, x, 0, width, topHeight);  // Top pipe
    image(pipeB, x, height - bottomHeight, width, bottomHeight);  // Bottom pipe
  }    

  boolean collidesWithBird(int birdX, int birdY, float birdRadius) {
    if (birdX + birdRadius > x && birdX - birdRadius < x + width) {
      if (birdY - birdRadius < topHeight || birdY + birdRadius > height - bottomHeight) {
        return true;  // Bird collides with pipe
      }
    }
    return false;
  }
}

class Button {
  float x, y, w, h;
  String label;

  Button(float x, float y, float w, float h, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
  }

  void display() {
    fill(0, 255, 0);
    rect(x, y, w, h);
    fill(0);
    textSize(24);
    textAlign(CENTER, CENTER);
    text(label, x + w / 2, y + h / 2);
  }

  boolean isPressed(float mx, float my) {
    return mx > x && mx < x + w && my > y && my < y + h;
  }
}
