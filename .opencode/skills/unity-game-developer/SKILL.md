---
name: unity-game-developer
description: "Expert Unity game development including 2D/3D games, C# scripting, game mechanics, and cross-platform publishing"
---

# Unity Game Developer

## Overview

This skill helps you build 2D and 3D games using Unity game engine with C# scripting.

## When to Use This Skill

- Use when building 2D or 3D games
- Use when creating game mechanics
- Use when implementing game systems

## How It Works

### Step 1: Project Structure

```text
MyGame/
├── Assets/
│   ├── Scripts/
│   │   ├── Core/           # Core systems
│   │   ├── Player/         # Player logic
│   │   ├── Enemies/        # Enemy AI
│   │   ├── UI/             # UI scripts
│   │   └── Managers/       # Game managers
│   ├── Prefabs/
│   ├── Scenes/
│   ├── Materials/
│   ├── Textures/
│   ├── Audio/
│   └── Animations/
├── Packages/
└── ProjectSettings/
```

### Step 2: Player Controller

```csharp
// Scripts/Player/PlayerController.cs
using UnityEngine;

[RequireComponent(typeof(Rigidbody2D))]
public class PlayerController : MonoBehaviour
{
    [Header("Movement")]
    [SerializeField] private float moveSpeed = 5f;
    [SerializeField] private float jumpForce = 10f;
    
    [Header("Ground Check")]
    [SerializeField] private Transform groundCheck;
    [SerializeField] private float groundRadius = 0.2f;
    [SerializeField] private LayerMask groundLayer;
    
    private Rigidbody2D rb;
    private Animator animator;
    private bool isGrounded;
    private float horizontalInput;
    
    private void Awake()
    {
        rb = GetComponent<Rigidbody2D>();
        animator = GetComponent<Animator>();
    }
    
    private void Update()
    {
        // Input
        horizontalInput = Input.GetAxisRaw("Horizontal");
        
        // Ground check
        isGrounded = Physics2D.OverlapCircle(groundCheck.position, groundRadius, groundLayer);
        
        // Jump
        if (Input.GetButtonDown("Jump") && isGrounded)
        {
            rb.velocity = new Vector2(rb.velocity.x, jumpForce);
        }
        
        // Animation
        animator.SetFloat("Speed", Mathf.Abs(horizontalInput));
        animator.SetBool("IsGrounded", isGrounded);
        
        // Flip sprite
        if (horizontalInput != 0)
        {
            transform.localScale = new Vector3(Mathf.Sign(horizontalInput), 1, 1);
        }
    }
    
    private void FixedUpdate()
    {
        rb.velocity = new Vector2(horizontalInput * moveSpeed, rb.velocity.y);
    }
}
```

### Step 3: Game Manager (Singleton)

```csharp
// Scripts/Managers/GameManager.cs
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }
    
    [Header("Game State")]
    public int score;
    public int lives = 3;
    public bool isGameOver;
    
    public event System.Action<int> OnScoreChanged;
    public event System.Action OnGameOver;
    
    private void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        DontDestroyOnLoad(gameObject);
    }
    
    public void AddScore(int points)
    {
        score += points;
        OnScoreChanged?.Invoke(score);
    }
    
    public void LoseLife()
    {
        lives--;
        if (lives <= 0)
        {
            GameOver();
        }
    }
    
    public void GameOver()
    {
        isGameOver = true;
        OnGameOver?.Invoke();
        Time.timeScale = 0f;
    }
    
    public void RestartGame()
    {
        Time.timeScale = 1f;
        score = 0;
        lives = 3;
        isGameOver = false;
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
    }
}
```

### Step 4: Enemy AI

```csharp
// Scripts/Enemies/EnemyAI.cs
using UnityEngine;

public class EnemyAI : MonoBehaviour
{
    [Header("Patrol")]
    [SerializeField] private Transform[] waypoints;
    [SerializeField] private float moveSpeed = 2f;
    
    [Header("Detection")]
    [SerializeField] private float detectionRange = 5f;
    [SerializeField] private float attackRange = 1f;
    [SerializeField] private LayerMask playerLayer;
    
    private int currentWaypoint;
    private Transform player;
    private State currentState = State.Patrol;
    
    private enum State { Patrol, Chase, Attack }
    
    private void Update()
    {
        CheckForPlayer();
        
        switch (currentState)
        {
            case State.Patrol:
                Patrol();
                break;
            case State.Chase:
                ChasePlayer();
                break;
            case State.Attack:
                Attack();
                break;
        }
    }
    
    private void CheckForPlayer()
    {
        Collider2D hit = Physics2D.OverlapCircle(transform.position, detectionRange, playerLayer);
        
        if (hit != null)
        {
            player = hit.transform;
            float distance = Vector2.Distance(transform.position, player.position);
            currentState = distance <= attackRange ? State.Attack : State.Chase;
        }
        else
        {
            currentState = State.Patrol;
        }
    }
    
    private void Patrol()
    {
        if (waypoints.Length == 0) return;
        
        Transform target = waypoints[currentWaypoint];
        transform.position = Vector2.MoveTowards(
            transform.position, 
            target.position, 
            moveSpeed * Time.deltaTime
        );
        
        if (Vector2.Distance(transform.position, target.position) < 0.1f)
        {
            currentWaypoint = (currentWaypoint + 1) % waypoints.Length;
        }
    }
    
    private void ChasePlayer()
    {
        if (player == null) return;
        transform.position = Vector2.MoveTowards(
            transform.position,
            player.position,
            moveSpeed * 1.5f * Time.deltaTime
        );
    }
    
    private void Attack()
    {
        // Attack logic
        Debug.Log("Attacking player!");
    }
}
```

### Step 5: Object Pooling

```csharp
// Scripts/Core/ObjectPool.cs
using System.Collections.Generic;
using UnityEngine;

public class ObjectPool : MonoBehaviour
{
    [SerializeField] private GameObject prefab;
    [SerializeField] private int initialSize = 10;
    
    private Queue<GameObject> pool = new Queue<GameObject>();
    
    private void Start()
    {
        for (int i = 0; i < initialSize; i++)
        {
            CreateNewObject();
        }
    }
    
    private void CreateNewObject()
    {
        GameObject obj = Instantiate(prefab, transform);
        obj.SetActive(false);
        pool.Enqueue(obj);
    }
    
    public GameObject Get(Vector3 position, Quaternion rotation)
    {
        if (pool.Count == 0)
            CreateNewObject();
        
        GameObject obj = pool.Dequeue();
        obj.transform.position = position;
        obj.transform.rotation = rotation;
        obj.SetActive(true);
        return obj;
    }
    
    public void Return(GameObject obj)
    {
        obj.SetActive(false);
        pool.Enqueue(obj);
    }
}
```

## Best Practices

### ✅ Do This

- ✅ Use object pooling for frequent spawns
- ✅ Use ScriptableObjects for data
- ✅ Implement proper game states
- ✅ Profile performance regularly

### ❌ Avoid This

- ❌ Don't use Find() in Update
- ❌ Don't instantiate in hot paths
- ❌ Don't ignore garbage collection
- ❌ Don't hardcode values

## Related Skills

- `@senior-software-engineer` - Code patterns
- `@3d-web-experience` - 3D concepts
