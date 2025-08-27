"use client";

import dynamic from "next/dynamic";

const MapContainer = dynamic(
  async () => (await import("react-leaflet")).MapContainer,
  { ssr: false }
);
const TileLayer = dynamic(async () => (await import("react-leaflet")).TileLayer, {
  ssr: false,
});

export default function MapView() {
  return (
    <div className="w-full h-[300px] border rounded overflow-hidden">
      <MapContainer center={{ lat: 46.8182, lng: 8.2275 }} zoom={7} className="w-full h-full">
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OSM</a>'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />
      </MapContainer>
    </div>
  );
}


