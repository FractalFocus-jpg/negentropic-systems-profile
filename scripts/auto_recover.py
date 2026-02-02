#!/usr/bin/env python3
"""
UOS Auto-Recovery Monitor
Watches all agents and restarts any that crash
"""

import os
import sys
import time
import json
import subprocess
import psutil
from pathlib import Path
from datetime import datetime

# Configuration
AGENTS = {
    "sentinel": {"port": 3001, "priority": 0, "cmd": "python scripts/agents/sentinel/run.py"},
    "weaver": {"port": 3002, "priority": 1, "cmd": "python scripts/agents/weaver/run.py"},
    "hermes": {"port": 3003, "priority": 2, "cmd": "python scripts/agents/hermes/run.py"},
    "scribe": {"port": 3004, "priority": 3, "cmd": "python scripts/agents/scribe/run.py"},
    "ledger": {"port": 3005, "priority": 4, "cmd": "python scripts/agents/ledger/run.py"},
    "janus": {"port": 3006, "priority": 5, "cmd": "python scripts/agents/janus/run.py"},
    "choir": {"port": 3007, "priority": 6, "cmd": "python scripts/agents/choir/run.py"}
}

MONITOR_PORT = 8765
MONITOR_CMD = "python src/tapestry/monitor.py"

CHECK_INTERVAL = 30  # seconds
MAX_RESTART_ATTEMPTS = 3
RESTART_COOLDOWN = 60  # seconds between restart attempts

class ProcessMonitor:
    def __init__(self):
        self.agent_processes = {}
        self.restart_counts = {}
        self.last_restart_time = {}
        self.monitor_process = None
        
    def is_port_listening(self, port):
        """Check if a port is being listened on"""
        for conn in psutil.net_connections():
            if conn.laddr.port == port and conn.status == 'LISTEN':
                return True
        return False
    
    def start_agent(self, agent_name, config):
        """Start an agent process"""
        try:
            print(f"🚀 Starting {agent_name}...")
            process = subprocess.Popen(
                config["cmd"],
                shell=True,
                cwd=Path(__file__).parent.parent,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            self.agent_processes[agent_name] = process
            self.restart_counts[agent_name] = self.restart_counts.get(agent_name, 0)
            print(f"✅ {agent_name} started (PID: {process.pid})")
            return True
        except Exception as e:
            print(f"❌ Failed to start {agent_name}: {e}")
            return False
    
    def start_monitor(self):
        """Start the FastAPI monitor"""
        try:
            print(f"🔍 Starting monitor on port {MONITOR_PORT}...")
            process = subprocess.Popen(
                MONITOR_CMD,
                shell=True,
                cwd=Path(__file__).parent.parent,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            self.monitor_process = process
            print(f"✅ Monitor started (PID: {process.pid})")
            return True
        except Exception as e:
            print(f"❌ Failed to start monitor: {e}")
            return False
    
    def check_agent(self, agent_name, config):
        """Check if agent is running and restart if needed"""
        port = config["port"]
        
        # Check if port is listening
        if self.is_port_listening(port):
            return True
        
        # Check if we've restarted too many times
        if self.restart_counts.get(agent_name, 0) >= MAX_RESTART_ATTEMPTS:
            last_restart = self.last_restart_time.get(agent_name, 0)
            if time.time() - last_restart < RESTART_COOLDOWN * MAX_RESTART_ATTEMPTS:
                print(f"⚠️  {agent_name} exceeded restart limit, waiting...")
                return False
            else:
                # Reset counter after cooldown
                self.restart_counts[agent_name] = 0
        
        # Attempt restart
        print(f"🔄 {agent_name} not responding on port {port}, restarting...")
        
        # Kill old process if exists
        if agent_name in self.agent_processes:
            try:
                self.agent_processes[agent_name].terminate()
                self.agent_processes[agent_name].wait(timeout=5)
            except:
                try:
                    self.agent_processes[agent_name].kill()
                except:
                    pass
        
        # Start new process
        success = self.start_agent(agent_name, config)
        if success:
            self.restart_counts[agent_name] = self.restart_counts.get(agent_name, 0) + 1
            self.last_restart_time[agent_name] = time.time()
            
            # Wait for startup
            time.sleep(5)
            
            # Verify it started
            if self.is_port_listening(port):
                print(f"✅ {agent_name} recovered successfully")
                return True
            else:
                print(f"❌ {agent_name} failed to start")
                return False
        
        return False
    
    def check_monitor(self):
        """Check if monitor is running and restart if needed"""
        if self.is_port_listening(MONITOR_PORT):
            return True
        
        print(f"🔄 Monitor not responding on port {MONITOR_PORT}, restarting...")
        
        # Kill old process if exists
        if self.monitor_process:
            try:
                self.monitor_process.terminate()
                self.monitor_process.wait(timeout=5)
            except:
                try:
                    self.monitor_process.kill()
                except:
                    pass
        
        # Start new process
        success = self.start_monitor()
        if success:
            time.sleep(5)
            if self.is_port_listening(MONITOR_PORT):
                print(f"✅ Monitor recovered successfully")
                return True
            else:
                print(f"❌ Monitor failed to start")
                return False
        
        return False
    
    def log_status(self):
        """Log current system status"""
        status = {
            "timestamp": datetime.now().isoformat(),
            "monitor": {
                "running": self.is_port_listening(MONITOR_PORT),
                "pid": self.monitor_process.pid if self.monitor_process else None
            },
            "agents": {}
        }
        
        for agent_name, config in AGENTS.items():
            status["agents"][agent_name] = {
                "running": self.is_port_listening(config["port"]),
                "port": config["port"],
                "restart_count": self.restart_counts.get(agent_name, 0),
                "pid": self.agent_processes[agent_name].pid if agent_name in self.agent_processes else None
            }
        
        # Write to logs
        log_file = Path(__file__).parent.parent / "logs" / f"recovery_{datetime.now().strftime('%Y-%m-%d')}.log"
        log_file.parent.mkdir(exist_ok=True)
        
        with open(log_file, 'a') as f:
            f.write(json.dumps(status, indent=2) + "\n")
        
        return status
    
    def run(self):
        """Main monitoring loop"""
        print("⬢ UOS Auto-Recovery Monitor Starting...")
        print(f"📊 Monitoring {len(AGENTS)} agents + monitor")
        print(f"🔄 Check interval: {CHECK_INTERVAL}s")
        print(f"🚨 Max restart attempts: {MAX_RESTART_ATTEMPTS}")
        print()
        
        # Initial startup
        self.check_monitor()
        time.sleep(2)
        
        for agent_name, config in sorted(AGENTS.items(), key=lambda x: x[1]["priority"]):
            self.check_agent(agent_name, config)
            time.sleep(1)
        
        print()
        print("✅ Initial startup complete")
        print("🔄 Entering monitoring loop...")
        print("Press Ctrl+C to stop")
        print()
        
        try:
            while True:
                # Check monitor
                self.check_monitor()
                
                # Check all agents
                for agent_name, config in AGENTS.items():
                    self.check_agent(agent_name, config)
                
                # Log status
                status = self.log_status()
                
                # Print summary
                running_agents = sum(1 for a in status["agents"].values() if a["running"])
                print(f"⬢ Status: Monitor={'✅' if status['monitor']['running'] else '❌'} | "
                      f"Agents={running_agents}/{len(AGENTS)} | "
                      f"Time={datetime.now().strftime('%H:%M:%S')}")
                
                # Wait for next check
                time.sleep(CHECK_INTERVAL)
                
        except KeyboardInterrupt:
            print("\n🛑 Shutting down monitor...")
            
            # Clean shutdown
            if self.monitor_process:
                self.monitor_process.terminate()
            
            for agent_name, process in self.agent_processes.items():
                if process:
                    process.terminate()
            
            print("✅ Clean shutdown complete")

if __name__ == "__main__":
    monitor = ProcessMonitor()
    monitor.run()
