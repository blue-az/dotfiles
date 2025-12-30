# Issue Tracking

Machine-specific issue tracking is in each machine's folder.

## Machine Issues

| Machine | Path |
|---------|------|
| Desktop (NVIDIA/Intel) | [machines/desktop/ISSUES.md](machines/desktop/ISSUES.md) |
| Z13 AMD (ROG Flow) | [machines/z13-amd/ISSUES.md](machines/z13-amd/ISSUES.md) |

## Adding New Issues

Create `ISSUES.md` in the appropriate `machines/<machine>/` folder using this template:

```markdown
# <Machine> Issue Tracking

Hardware and software issues for <machine description>.

## Open Issues

### <Issue Title>
- **Status:** <Open/Testing fix/Monitoring>
- **Submitted:** <date>

#### Problem
<description>

#### Cause
<root cause if known>

#### Fix Applied
<fix details>

## Resolved Issues

### <Issue Title>
- **Status:** Resolved
- **Submitted:** <date>
- **Resolved:** <date>

#### Problem
<description>

#### Solution
<what fixed it>
```
