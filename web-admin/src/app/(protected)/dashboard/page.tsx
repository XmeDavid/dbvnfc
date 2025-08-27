"use client";

import MapView from "@/components/dashboard/MapView";
import TeamsTable from "@/components/dashboard/TeamsTable";
import EventsFeed from "@/components/dashboard/EventsFeed";

const mockTeams = [
  { id: "t1", name: "Red Foxes", completedBases: 2, score: 200 },
  { id: "t2", name: "Blue Owls", completedBases: 1, score: 120 },
];
const mockEvents = [
  { id: "e1", type: "tap", message: "Team Red Foxes arrived at Base 1", createdAt: new Date().toISOString() },
  { id: "e2", type: "solve", message: "Team Blue Owls solved Enigma #3", createdAt: new Date().toISOString() },
];

export default function DashboardPage() {
  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-semibold">Monitoring Dashboard</h1>
      <p className="text-sm text-foreground/70">Realtime overview of games and teams.</p>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <MapView />
        <div><TeamsTable teams={mockTeams} /></div>
        <div><EventsFeed events={mockEvents} /></div>
      </div>
    </div>
  );
}


