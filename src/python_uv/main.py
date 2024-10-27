def greet(name: str) -> str:
    return f"Hello, {name}!"


def calculate_sum(*args: int) -> int:
    return sum(args)


def main() -> None:
    print(greet("World"))
