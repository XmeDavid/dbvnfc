"use client";

import dynamic from "next/dynamic";
import { useMemo, useState } from "react";
import { z } from "zod";
import { v4 as uuidv4 } from "uuid";
import LocationPickerMap, { LatLng } from "@/components/maps/LocationPickerMap";
import { BaseLocation, Enigma } from "@/types/game";

const ReactQuill = dynamic(() => import("react-quill"), { ssr: false });

const baseSchema = z.object({
  id: z.string(),
  name: z.string().optional(),
  uuid: z.string(),
  latitude: z.number(),
  longitude: z.number(),
});

const enigmaSchema = z.object({
  id: z.string(),
  title: z.string().min(1),
  contentHtml: z.string().min(1),
  answerTemplate: z.string().optional(),
  mediaUrls: z.array(z.string().url()).optional(),
  fixedToBaseId: z.string().optional(),
});

const formSchema = z.object({
  name: z.string().min(1),
  rulesHtml: z.string().optional(),
  bases: z.array(baseSchema),
  enigmas: z.array(enigmaSchema),
});

export default function NewGamePage() {
  const [name, setName] = useState("");
  const [rules, setRules] = useState("");
  const [bases, setBases] = useState<BaseLocation[]>([]);
  const [enigmas, setEnigmas] = useState<Enigma[]>([]);
  const [error, setError] = useState<string | null>(null);

  const selected = useMemo<LatLng | null>(() => {
    const last = bases[bases.length - 1];
    return last ? { lat: last.latitude, lng: last.longitude } : null;
  }, [bases]);

  function addBaseFromPick(p: LatLng) {
    const newBase: BaseLocation = {
      id: uuidv4(),
      uuid: uuidv4(),
      latitude: p.lat,
      longitude: p.lng,
      name: `Base ${bases.length + 1}`,
    };
    setBases((prev) => [...prev, newBase]);
  }

  function addEnigma() {
    setEnigmas((prev) => [
      ...prev,
      { id: uuidv4(), title: "", contentHtml: "" },
    ]);
  }

  function updateEnigma(id: string, updates: Partial<Enigma>) {
    setEnigmas((prev) => prev.map((e) => (e.id === id ? { ...e, ...updates } : e)));
  }

  function removeEnigma(id: string) {
    setEnigmas((prev) => prev.filter((e) => e.id !== id));
  }

  async function onSave() {
    setError(null);
    const payload = { name, rulesHtml: rules, bases, enigmas };
    const parsed = formSchema.safeParse(payload);
    if (!parsed.success) {
      setError("Please complete required fields");
      return;
    }
    // TODO: POST to backend when available
    console.log("Game payload", payload);
    alert("Saved draft locally (backend not yet connected)");
  }

  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-semibold">Create Game</h1>
      <div className="grid gap-4 md:grid-cols-2">
        <div className="space-y-2">
          <label className="text-sm">Game name</label>
          <input
            className="w-full border rounded px-3 py-2 bg-transparent"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Night Quest 2025"
          />
          <label className="text-sm">Rules (HTML)</label>
          <ReactQuill theme="snow" value={rules} onChange={setRules} />
          <div className="pt-4">
            <div className="flex items-center justify-between">
              <h2 className="font-medium">Enigmas</h2>
              <button onClick={addEnigma} className="text-sm underline">Add</button>
            </div>
            <div className="space-y-4">
              {enigmas.map((e) => (
                <div key={e.id} className="border rounded p-3 space-y-2">
                  <input
                    className="w-full border rounded px-2 py-1 bg-transparent"
                    placeholder="Title"
                    value={e.title}
                    onChange={(ev) => updateEnigma(e.id, { title: ev.target.value })}
                  />
                  <ReactQuill
                    theme="snow"
                    value={e.contentHtml}
                    onChange={(val) => updateEnigma(e.id, { contentHtml: val })}
                  />
                  <div className="flex items-center gap-2">
                    <input
                      className="flex-1 border rounded px-2 py-1 bg-transparent"
                      placeholder="Answer template (optional)"
                      value={e.answerTemplate || ""}
                      onChange={(ev) => updateEnigma(e.id, { answerTemplate: ev.target.value })}
                    />
                    <button className="text-sm underline" onClick={() => removeEnigma(e.id)}>Remove</button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
        <div className="space-y-2">
          <label className="text-sm">Add base by clicking on the map</label>
          <div className="h-[420px] border rounded overflow-hidden">
            <LocationPickerMap value={selected} onChange={addBaseFromPick} className="h-full" />
          </div>
          <div className="space-y-2">
            {bases.map((b, i) => (
              <div key={b.id} className="flex items-center gap-2 text-sm">
                <span className="w-6 text-right">{i + 1}.</span>
                <input
                  className="border rounded px-2 py-1 bg-transparent flex-1"
                  value={b.name || ""}
                  onChange={(e) =>
                    setBases((prev) => prev.map((x) => (x.id === b.id ? { ...x, name: e.target.value } : x)))
                  }
                  placeholder="Base name"
                />
                <code className="text-xs px-2 py-1 bg-foreground/5 rounded">{b.uuid}</code>
              </div>
            ))}
          </div>
        </div>
      </div>
      {error && <p className="text-red-600 text-sm">{error}</p>}
      <button onClick={onSave} className="bg-foreground text-background rounded px-4 py-2">Save</button>
    </div>
  );
}


