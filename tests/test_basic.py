import unittest
from src.tapestry.model import Params, stable, step

class TestTapestry(unittest.TestCase):
    def test_gate(self):
        self.assertTrue(stable(Params(beta=0.8, D=0.9)))   # 0.72 < 1
        self.assertFalse(stable(Params(beta=1.2, D=1.0)))  # 1.2 > 1

    def test_evolve(self):
        p = Params(alpha=0.2, beta=0.8, D=0.9)
        C = 0.9
        for _ in range(5):
            C = step(C, p, 0.1)
        self.assertGreater(C, 0)  # sanity

if __name__ == "__main__":
    unittest.main()
