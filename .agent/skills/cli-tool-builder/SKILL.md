---
name: cli-tool-builder
description: "Expert in building command-line tools and CLIs with argument parsing, interactive prompts, and developer-friendly UX"
---

# CLI Tool Builder

## Overview

This skill helps you build professional command-line tools with great UX, proper argument parsing, and helpful output.

## When to Use This Skill

- Use when building CLI tools
- Use when automating workflows
- Use when creating developer tools
- Use when building scripts

## How It Works

### Step 1: Node.js CLI Structure

```typescript
#!/usr/bin/env node
// src/index.ts
import { Command } from 'commander';
import chalk from 'chalk';
import ora from 'ora';

const program = new Command();

program
  .name('mytool')
  .description('A helpful CLI tool')
  .version('1.0.0');

program
  .command('init')
  .description('Initialize a new project')
  .option('-n, --name <name>', 'Project name')
  .option('-t, --template <template>', 'Template to use', 'default')
  .action(async (options) => {
    const spinner = ora('Creating project...').start();
    try {
      await createProject(options.name, options.template);
      spinner.succeed(chalk.green('Project created!'));
    } catch (error) {
      spinner.fail(chalk.red('Failed to create project'));
      process.exit(1);
    }
  });

program.parse();
```

### Step 2: Interactive Prompts

```typescript
import inquirer from 'inquirer';

async function promptConfig() {
  const answers = await inquirer.prompt([
    {
      type: 'input',
      name: 'name',
      message: 'Project name:',
      validate: (input) => input.length > 0 || 'Name required'
    },
    {
      type: 'list',
      name: 'template',
      message: 'Choose a template:',
      choices: ['react', 'vue', 'next', 'node']
    },
    {
      type: 'confirm',
      name: 'typescript',
      message: 'Use TypeScript?',
      default: true
    },
    {
      type: 'checkbox',
      name: 'features',
      message: 'Select features:',
      choices: ['ESLint', 'Prettier', 'Testing', 'CI/CD']
    }
  ]);
  
  return answers;
}
```

### Step 3: Output Formatting

```typescript
import chalk from 'chalk';
import boxen from 'boxen';
import { table } from 'table';

// Colored output
console.log(chalk.green('✓ Success'));
console.log(chalk.red('✗ Error'));
console.log(chalk.yellow('⚠ Warning'));
console.log(chalk.blue('ℹ Info'));

// Boxed output
console.log(boxen(
  `${chalk.green('Project created!')}\n\nNext steps:\n  cd my-project\n  npm install`,
  { padding: 1, borderColor: 'green' }
));

// Table output
const data = [
  ['Name', 'Size', 'Status'],
  ['index.js', '2.3kb', chalk.green('✓')],
  ['styles.css', '1.1kb', chalk.green('✓')]
];
console.log(table(data));
```

### Step 4: Package Configuration

```json
{
  "name": "my-cli",
  "version": "1.0.0",
  "bin": {
    "mytool": "./dist/index.js"
  },
  "files": ["dist"],
  "scripts": {
    "build": "tsc",
    "dev": "ts-node src/index.ts"
  },
  "dependencies": {
    "commander": "^12.0.0",
    "chalk": "^5.0.0",
    "inquirer": "^9.0.0",
    "ora": "^8.0.0"
  }
}
```

## Best Practices

### ✅ Do This

- ✅ Include --help and --version
- ✅ Use colors meaningfully
- ✅ Show progress for long tasks
- ✅ Handle errors gracefully
- ✅ Support stdin/stdout piping

### ❌ Avoid This

- ❌ Don't output noise
- ❌ Don't require unnecessary flags
- ❌ Don't fail silently
- ❌ Don't ignore exit codes

## Related Skills

- `@senior-nodejs-developer` - Node.js
- `@senior-typescript-developer` - TypeScript
