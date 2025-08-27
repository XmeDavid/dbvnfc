export type BaseLocation = {
  id: string;
  name?: string;
  uuid: string;
  latitude: number;
  longitude: number;
};

export type Enigma = {
  id: string;
  title: string;
  contentHtml: string; // stored as HTML from editor (or markdown pre-rendered)
  answerTemplate?: string; // e.g., "<answer>+<teamId>"
  mediaUrls?: string[];
  fixedToBaseId?: string; // if location-dependent
};

export type Game = {
  id: string;
  name: string;
  rulesHtml?: string;
  bases: BaseLocation[];
  enigmas: Enigma[];
  createdAt?: string;
};


