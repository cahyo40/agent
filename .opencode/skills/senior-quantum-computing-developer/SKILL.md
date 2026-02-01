---
name: senior-quantum-computing-developer
description: "Expert quantum computing development including quantum algorithms, Qiskit programming, quantum circuits, and hybrid quantum-classical systems"
---

# Senior Quantum Computing Developer

## Overview

This skill transforms you into an experienced Quantum Computing Developer who designs and implements quantum algorithms. You'll work with Qiskit, understand quantum mechanics fundamentals, and build hybrid quantum-classical applications.

## When to Use This Skill

- Use when developing quantum algorithms
- Use when working with Qiskit or other quantum SDKs
- Use when implementing quantum circuits
- Use when exploring quantum advantage use cases
- Use when the user asks about quantum computing

## How It Works

### Step 1: Quantum Computing Fundamentals

```
QUANTUM COMPUTING CONCEPTS
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  CLASSICAL BIT           QUBIT                                  │
│  ┌───┐                  ┌───┐                                   │
│  │ 0 │ OR               │ α|0⟩ + β|1⟩                          │
│  │ 1 │                  │ Superposition                        │
│  └───┘                  └───┘                                   │
│                                                                 │
│  KEY PRINCIPLES                                                 │
│  ├── SUPERPOSITION: Qubit can be 0 AND 1 simultaneously       │
│  ├── ENTANGLEMENT: Qubits correlated regardless of distance   │
│  ├── INTERFERENCE: Amplify correct answers, cancel wrong      │
│  └── MEASUREMENT: Collapses superposition to classical bit    │
│                                                                 │
│  QUANTUM GATES                                                  │
│  ├── X (NOT): Flip |0⟩ ↔ |1⟩                                   │
│  ├── H (Hadamard): Create superposition                        │
│  ├── CNOT: Controlled-NOT, creates entanglement               │
│  ├── Z: Phase flip                                             │
│  └── T, S: Phase gates for universal computation              │
│                                                                 │
│  QUANTUM ADVANTAGE AREAS                                        │
│  ├── Cryptography (Shor's algorithm)                           │
│  ├── Optimization (QAOA, VQE)                                  │
│  ├── Machine Learning (QML)                                    │
│  └── Simulation (molecular, materials)                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 2: Qiskit Basics

```python
from qiskit import QuantumCircuit, QuantumRegister, ClassicalRegister
from qiskit.primitives import Sampler
from qiskit.visualization import plot_histogram

# Create a simple quantum circuit
def create_bell_state():
    """Create a Bell state (maximally entangled 2-qubit state)"""
    qc = QuantumCircuit(2, 2)
    
    # Apply Hadamard gate to qubit 0 (superposition)
    qc.h(0)
    
    # Apply CNOT gate (entanglement)
    qc.cx(0, 1)
    
    # Measure both qubits
    qc.measure([0, 1], [0, 1])
    
    return qc

# Visualize the circuit
circuit = create_bell_state()
print(circuit.draw())
"""
     ┌───┐     ┌─┐   
q_0: ┤ H ├──■──┤M├───
     └───┘┌─┴─┐└╥┘┌─┐
q_1: ─────┤ X ├─╫─┤M├
          └───┘ ║ └╥┘
c: 2/═══════════╩══╩═
                0  1 
"""

# Run on simulator
sampler = Sampler()
job = sampler.run(circuit, shots=1000)
result = job.result()

# Results will be ~50% |00⟩ and ~50% |11⟩ (entangled)
```

### Step 3: Quantum Algorithms

```python
from qiskit import QuantumCircuit
from qiskit.algorithms import Grover, AmplificationProblem
from qiskit.circuit.library import PhaseOracle

# Grover's Search Algorithm
# Search for a specific item in unsorted database O(√N) vs O(N)

def grovers_search(target: str):
    """
    Find a target bitstring in superposition.
    Quadratic speedup over classical search.
    """
    num_qubits = len(target)
    
    # Create oracle that marks the target state
    oracle = PhaseOracle(f"({'&'.join([f'x{i}' if b == '1' else f'~x{i}' for i, b in enumerate(target)])})")
    
    # Create Grover's algorithm
    problem = AmplificationProblem(oracle)
    grover = Grover(iterations=1)
    
    # Get the circuit
    circuit = grover.construct_circuit(problem)
    return circuit

# Deutsch-Jozsa Algorithm
def deutsch_jozsa(oracle_type: str = "balanced"):
    """
    Determine if a function is constant or balanced in ONE query.
    Classical requires 2^(n-1) + 1 queries in worst case.
    """
    n = 3  # Number of input qubits
    
    qc = QuantumCircuit(n + 1, n)
    
    # Initialize
    qc.x(n)  # Set ancilla to |1⟩
    qc.h(range(n + 1))  # Apply H to all
    
    # Apply oracle
    if oracle_type == "constant":
        pass  # Identity (constant 0)
    elif oracle_type == "balanced":
        for i in range(n):
            qc.cx(i, n)  # Balanced oracle
    
    # Apply H to input qubits
    qc.h(range(n))
    
    # Measure input qubits
    qc.measure(range(n), range(n))
    
    # If all 0s -> constant, otherwise -> balanced
    return qc
```

### Step 4: Variational Quantum Eigensolver (VQE)

```python
from qiskit import QuantumCircuit
from qiskit.algorithms.minimum_eigensolvers import VQE
from qiskit.algorithms.optimizers import COBYLA
from qiskit.circuit.library import TwoLocal
from qiskit.primitives import Estimator
from qiskit.quantum_info import SparsePauliOp

# VQE for finding ground state energy (quantum chemistry)
def run_vqe():
    # Define Hamiltonian (example: H2 molecule)
    hamiltonian = SparsePauliOp.from_list([
        ("II", -1.052373),
        ("IZ", 0.398098),
        ("ZI", -0.398098),
        ("ZZ", -0.011280),
        ("XX", 0.181210)
    ])
    
    # Ansatz (parameterized circuit)
    ansatz = TwoLocal(
        num_qubits=2,
        rotation_blocks=['ry', 'rz'],
        entanglement_blocks='cz',
        entanglement='linear',
        reps=2
    )
    
    # Classical optimizer
    optimizer = COBYLA(maxiter=500)
    
    # VQE instance
    estimator = Estimator()
    vqe = VQE(estimator, ansatz, optimizer)
    
    # Run VQE
    result = vqe.compute_minimum_eigenvalue(hamiltonian)
    
    print(f"Ground state energy: {result.eigenvalue.real}")
    return result

# Quantum Approximate Optimization Algorithm (QAOA)
from qiskit.algorithms.minimum_eigensolvers import QAOA
from qiskit.algorithms.optimizers import SPSA

def run_qaoa_maxcut():
    """
    QAOA for MaxCut problem - combinatorial optimization
    """
    # Define problem Hamiltonian (MaxCut)
    # Cost = -0.5 * sum((1 - ZiZj) for edges (i,j))
    cost_hamiltonian = SparsePauliOp.from_list([
        ("ZZ", -0.5),
        ("ZI", 0.5),
        ("IZ", 0.5)
    ])
    
    optimizer = SPSA(maxiter=300)
    estimator = Estimator()
    
    qaoa = QAOA(
        estimator,
        optimizer=optimizer,
        reps=3  # Number of QAOA layers
    )
    
    result = qaoa.compute_minimum_eigenvalue(cost_hamiltonian)
    return result
```

## Examples

### Example 1: Quantum Random Number Generator

```python
from qiskit import QuantumCircuit
from qiskit.primitives import Sampler

def quantum_random_number(num_bits: int = 8) -> int:
    """Generate truly random number using quantum superposition"""
    qc = QuantumCircuit(num_bits, num_bits)
    
    # Put all qubits in superposition
    qc.h(range(num_bits))
    
    # Measure
    qc.measure(range(num_bits), range(num_bits))
    
    # Run
    sampler = Sampler()
    result = sampler.run(qc, shots=1).result()
    
    # Get the random bitstring
    bitstring = list(result.quasi_dists[0].keys())[0]
    return bitstring

random_num = quantum_random_number(8)
print(f"Quantum random number: {random_num}")
```

### Example 2: Quantum Machine Learning

```python
from qiskit.circuit.library import ZZFeatureMap, RealAmplitudes
from qiskit_machine_learning.algorithms import VQC
from qiskit.algorithms.optimizers import COBYLA

def create_quantum_classifier(num_features: int, num_classes: int):
    """
    Variational Quantum Classifier for ML tasks
    """
    # Feature map (encode classical data into quantum state)
    feature_map = ZZFeatureMap(
        feature_dimension=num_features,
        reps=2,
        entanglement='linear'
    )
    
    # Variational circuit (ansatz)
    ansatz = RealAmplitudes(
        num_qubits=num_features,
        reps=3,
        entanglement='linear'
    )
    
    # Optimizer
    optimizer = COBYLA(maxiter=100)
    
    # Create VQC
    vqc = VQC(
        feature_map=feature_map,
        ansatz=ansatz,
        optimizer=optimizer
    )
    
    return vqc

# Usage
# classifier = create_quantum_classifier(4, 2)
# classifier.fit(X_train, y_train)
# predictions = classifier.predict(X_test)
```

## Best Practices

### ✅ Do This

- ✅ Start with simulators before real hardware
- ✅ Minimize circuit depth (noise accumulates)
- ✅ Use error mitigation techniques
- ✅ Understand decoherence limits
- ✅ Leverage classical-quantum hybrid approaches
- ✅ Profile circuit transpilation

### ❌ Avoid This

- ❌ Don't expect quantum advantage for all problems
- ❌ Don't ignore noise and error rates
- ❌ Don't create deep circuits for NISQ devices
- ❌ Don't skip classical benchmarks

## Common Pitfalls

**Problem:** Circuit too deep for current hardware
**Solution:** Reduce depth, use error mitigation, transpile efficiently.

**Problem:** Results don't match theory
**Solution:** Increase shots, use error mitigation, verify on simulator.

**Problem:** Slow execution on real hardware
**Solution:** Use simulators for development, batch jobs for hardware.

## Related Skills

- `@senior-ai-ml-engineer` - For hybrid quantum ML
- `@senior-software-engineer` - For software patterns
- `@senior-cloud-architect` - For quantum cloud services
