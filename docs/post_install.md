# Post-Installation Setup

## Prompt Configuration

The dotfiles use Powerlevel10k for the shell prompt. The prompt configuration is intentionally not included in the repository to allow each host to maintain its own personalized prompt settings.

### Configure Powerlevel10k

Powerlevel10k is installed via Zinit. To configure your prompt:

```bash
# Run the configuration wizard
p10k configure
```

This will create a `~/.p10k.zsh` file with your personalized settings.

### Prompt Tips

For maximum typing space:
- Use a two-line prompt layout
- Minimize or disable the right prompt
- Consider hiding language version indicators unless needed

## Next Steps

- Restart your terminal or run `source ~/.zshrc`
- Configure your prompt using `p10k configure`
- Enjoy your new development environment!
