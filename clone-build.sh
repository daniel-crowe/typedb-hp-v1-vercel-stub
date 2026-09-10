#!/bin/sh
set -eu
if [ -f public/instruments/pass-b-chat-v4.1.html ]; then
  mkdir -p /tmp/typedb-stash
  cp public/instruments/pass-b-chat-v4.1.html /tmp/typedb-stash/pass-b-chat-v4.1.html
fi
rm -rf /tmp/typedb-site
git clone --depth 1 --branch main https://github.com/daniel-crowe/typedb-hp-v1-pr3-src.git /tmp/typedb-site
python3 <<'PY'
import base64, shutil
from pathlib import Path

def decode(text):
    compact = "".join(text.split())
    compact += "=" * ((4 - len(compact) % 4) % 4)
    return base64.b64decode(compact)

def decode_monaco(text):
    compact = "".join(text.split())
    # GitHub file API inserted one extra O at stripped index 23161 (24013 vs 24012).
    if len(compact) == 24013 and compact[23155:23170] == "rgN3ysOOOgrDnnM":
        compact = compact[:23161] + compact[23162:]
    compact += "=" * ((4 - len(compact) % 4) % 4)
    return base64.b64decode(compact)

clone = Path("/tmp/typedb-site")
src = clone / "fonts-b64"
for dest in (clone / "app/fonts", clone / "public/fonts"):
    dest.mkdir(parents=True, exist_ok=True)
    for path in src.glob("*.b64"):
        raw = path.read_text()
        data = decode_monaco(raw) if path.name == "Monaco.woff2.b64" else decode(raw)
        dest.joinpath(path.name[:-4]).write_bytes(data)

skip = {"clone-build.sh", ".git", "monaco.b64"}
cwd = Path.cwd()
for item in clone.iterdir():
    if item.name in skip:
        continue
    target = cwd / item.name
    if target.exists():
        if target.is_dir():
            shutil.rmtree(target)
        else:
            target.unlink()
    if item.is_dir():
        shutil.copytree(item, target)
    else:
        shutil.copy2(item, target)

monaco_b64 = Path("monaco.b64")
if monaco_b64.exists() and monaco_b64.stat().st_size > 1000:
    data = decode_monaco(monaco_b64.read_text())
    for dest in (Path("app/fonts"), Path("public/fonts")):
        dest.mkdir(parents=True, exist_ok=True)
        dest.joinpath("Monaco.woff2").write_bytes(data)
    print("wrote stub Monaco", len(data))

monaco = Path("public/fonts/Monaco.woff2").read_bytes()
print("monaco bytes", len(monaco), "magic", monaco[:4])
if len(monaco) != 18008 or monaco[:4] != b"wOF2":
    raise SystemExit("Monaco.woff2 is not the known-good 18008-byte woff2")
print("fonts", sorted(p.name for p in Path("public/fonts").iterdir()))
print("app files", sorted(p.name for p in Path("app").iterdir()))
PY
python3 <<'PY'
from pathlib import Path
Path("app").mkdir(parents=True, exist_ok=True)
Path("app/marks.css").write_text(r'''/* Daniel marks on PR3 — last-loaded so lock.css does not win. */

#ai-systems,
#ai-systems.section-proof,
#suite.section-proof,
.section-proof:not(#neo4j) {
  background: transparent;
  border-block: none;
}

#ai-systems.section-proof:has(.passb-iframe-wrap) {
  padding-top: 36px;
}

.ai-systems-head {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin: 0 0 8px;
  text-align: center;
}

.ai-systems-head .section-title {
  max-width: none;
  margin: 0;
  font-size: clamp(32px, 4vw, 38px);
  font-weight: 520;
  letter-spacing: -0.025em;
  line-height: 1.15;
}

.passb-iframe-wrap {
  width: 100%;
  max-width: 100%;
  margin: 0;
  margin-left: 0;
  overflow: hidden;
  background: transparent;
}

.passb-iframe {
  display: block;
  width: 100%;
  height: 920px;
  border: 0;
  overflow: hidden;
  background: transparent;
  color-scheme: normal;
}

@media (max-width: 768px) {
  .passb-iframe {
    height: 980px;
  }
}

.ai-pillars {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 16px;
  margin: 0 0 40px;
  padding: 0;
  list-style: none;
}

.ai-pillars li {
  display: grid;
  grid-template-columns: 36px 1fr;
  gap: 14px;
  min-height: 100%;
  padding: 22px 20px 20px;
  border: 1px solid var(--raised);
  border-radius: 8px;
  background: #12101d;
}

.ai-pillars span {
  color: #01e870;
  font-family: var(--font-family-code);
  font-size: 13px;
}

.ai-pillars h3 {
  margin: 0 0 8px;
  font-size: 18px;
  font-weight: 500;
}

.ai-pillars p {
  margin: 0;
  max-width: none;
  color: var(--mute);
  font-size: 15px;
}

.ai-audit-title {
  margin: 0 0 12px;
  font-size: clamp(22px, 3vw, 30px);
  font-weight: 500;
}

.audit-metrics {
  display: grid;
  grid-template-columns: 1fr;
  gap: 0;
  max-width: 62ch;
  margin: 36px 0 0;
  padding: 0;
  border-block: 1px solid color-mix(in srgb, #01e870 32%, #2a2a36);
}

.audit-metrics div {
  display: grid;
  grid-template-columns: minmax(7rem, 11rem) 1fr;
  gap: 16px;
  align-items: baseline;
  padding: 18px 0;
  text-align: left;
  border-bottom: 1px solid color-mix(in srgb, #01e870 32%, #2a2a36);
}

.audit-metrics div:last-child {
  border-bottom: 0;
}

.audit-metrics dt {
  margin: 0;
  color: var(--ink);
  font-size: clamp(22px, 2.5vw, 32px);
  font-weight: 600;
  letter-spacing: -0.03em;
  line-height: 1.15;
}

.audit-metrics dd {
  margin: 0;
  color: var(--mute-2);
  font-size: 14px;
  line-height: 1.35;
}

.section-proof {
  background: transparent;
  border-block: none;
}

#suite.section-proof {
  background: transparent;
  border-block: none;
}

#neo4j.section-proof {
  background: var(--deep);
  border-block: 1px solid var(--line);
}

.hero.is-pack {
  align-items: center;
  min-height: auto;
  padding: 72px 0 56px;
  text-align: center;
}

.hero.is-pack .hero-copy {
  max-width: 46rem;
  padding: 0;
}

.hero.is-pack h1 {
  max-width: 18ch;
  margin-inline: auto;
}

.hero.is-pack .hero-sub {
  margin-inline: auto;
}

.hero.is-pack .hero-actions {
  justify-content: center;
}

.analytics-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 16px;
  margin: 36px 0 0;
  padding: 0;
  list-style: none;
}

.analytics-card {
  display: flex;
  flex-direction: column;
  min-height: 100%;
  padding: 22px 20px 20px;
  border: 1px solid var(--raised);
  border-radius: 8px;
  background: #12101d;
}

.analytics-card span {
  color: #01e870;
  font-family: var(--font-family-code);
  font-size: 12px;
}

.analytics-card h3 {
  margin: 10px 0 10px;
  font-size: 18px;
  font-weight: 500;
}

.analytics-card p {
  margin: 0 0 16px;
  color: var(--mute);
  font-size: 15px;
}

.analytics-card a {
  margin-top: auto;
  color: var(--ink);
  font-size: 14px;
  text-decoration: none;
}

.analytics-card a:hover {
  color: #01e870;
}

.neo4j-strip {
  display: grid;
  gap: 10px;
}

.neo4j-question {
  margin: 0;
  font-size: clamp(24px, 3vw, 34px);
  font-weight: 500;
}

.neo4j-strip a {
  color: #01e870;
  text-decoration: none;
}

@media (max-width: 900px) {
  .ai-pillars,
  .analytics-grid {
    grid-template-columns: 1fr;
    gap: 12px;
  }

  .audit-metrics div {
    grid-template-columns: 1fr;
    gap: 4px;
  }
}

.usage-strip {
  padding: 28px 0 8px;
}

.usage-counts {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 18px;
  margin: 0;
}

.usage-counts dt {
  margin: 0 0 6px;
  color: var(--mute-2);
  font-size: 13px;
}

.usage-counts dd {
  margin: 0;
  color: var(--ink);
  font-family: var(--font-family-code);
  font-size: clamp(22px, 3vw, 32px);
  font-weight: 500;
  letter-spacing: -0.03em;
  font-variant-numeric: tabular-nums;
}

.logo-bar {
  padding: 12px 0 48px;
  overflow: hidden;
}

.logo-bar .eyebrow {
  margin-bottom: 18px;
}

.logo-track-wrap {
  overflow: hidden;
  mask-image: linear-gradient(90deg, transparent, #000 8%, #000 92%, transparent);
}

.logo-track {
  display: flex;
  gap: 48px;
  width: max-content;
  margin: 0;
  padding: 0;
  list-style: none;
  animation: logo-scroll 42s linear infinite;
}

.logo-track li {
  color: var(--mute);
  font-size: 18px;
  font-weight: 500;
  letter-spacing: -0.02em;
  white-space: nowrap;
}

.logo-track-wrap:hover .logo-track {
  animation-play-state: paused;
}

@keyframes logo-scroll {
  from { transform: translateX(0); }
  to { transform: translateX(-50%); }
}

.blog-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
  margin: 36px 0 0;
  padding: 0;
  list-style: none;
}

.blog-card {
  display: flex;
  flex-direction: column;
  min-height: 100%;
  padding: 22px 20px 20px;
  border: 1px solid var(--raised);
  border-radius: 8px;
  background: #12101d;
  text-decoration: none;
}

.blog-date {
  margin: 0 0 10px;
  color: #01e870;
  font-family: var(--font-family-code);
  font-size: 12px;
}

.blog-card h3 {
  margin: 0 0 10px;
  font-size: 18px;
  font-weight: 500;
}

.blog-card p:last-child {
  margin: 0;
  color: var(--mute);
  font-size: 15px;
}

.blog-more {
  margin: 24px 0 0;
}

.blog-more a {
  color: #01e870;
  text-decoration: none;
}

.footer-tools {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 28px;
  align-items: end;
  margin-top: 32px;
}

.footer-socials {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
}

.footer-subscribe label {
  display: block;
  margin: 0 0 10px;
  color: var(--ink);
  font-size: 13px;
  font-weight: 500;
}

.footer-subscribe-row {
  display: flex;
  gap: 8px;
}

.footer-subscribe input {
  flex: 1;
  min-height: 40px;
  padding: 0 12px;
  border: 1px solid var(--raised);
  border-radius: 4px;
  background: #12101d;
  color: var(--ink);
  font: inherit;
  font-size: 14px;
}

.footer-subscribe button {
  min-height: 40px;
  padding: 0 14px;
  border: 0;
  border-radius: 4px;
  background: var(--accent);
  color: #041614;
  font: inherit;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
}

@media (max-width: 768px) {
  .usage-counts,
  .blog-grid,
  .footer-tools {
    grid-template-columns: 1fr;
  }

  .logo-track {
    animation: none;
    flex-wrap: wrap;
    width: auto;
    gap: 16px 24px;
    padding: 0 20px;
  }

  .logo-track-wrap {
    mask-image: none;
  }
}

@media (prefers-reduced-motion: reduce) {
  .logo-track {
    animation: none;
    flex-wrap: wrap;
    width: auto;
    max-width: 1120px;
    margin-inline: auto;
    padding: 0 20px;
  }
}

.share-gate {
  position: fixed;
  inset: 0;
  z-index: 80;
  display: grid;
  place-items: center;
  padding: 24px;
  background: var(--page);
}

.share-gate-form {
  width: min(28rem, 100%);
}

.share-gate-kicker {
  margin: 0 0 8px;
  color: var(--accent);
  font-size: 13px;
}

.share-gate h1 {
  margin: 0 0 16px;
  font-size: 28px;
  font-weight: 520;
  letter-spacing: -0.025em;
}

.share-gate-copy {
  margin: 0 0 20px;
  color: var(--mute);
}

.share-gate label {
  display: block;
  margin: 0 0 8px;
  font-size: 13px;
}

.share-gate input {
  width: 100%;
  min-height: 40px;
  padding: 0 12px;
  border: 1px solid var(--raised);
  border-radius: 4px;
  background: #12101d;
  color: var(--ink);
  font: inherit;
}

.share-gate-error {
  margin: 10px 0 0;
  color: var(--danger);
  font-size: 14px;
}

.share-gate button {
  margin-top: 16px;
  min-height: 40px;
  padding: 0 14px;
  border: 0;
  border-radius: 4px;
  background: var(--accent);
  color: #041614;
  font: inherit;
  font-weight: 500;
  cursor: pointer;
}
''')
print("overlaid app/marks.css", Path("app/marks.css").stat().st_size)
PY
if [ -f /tmp/typedb-stash/pass-b-chat-v4.1.html ]; then
  mkdir -p public/instruments
  cp /tmp/typedb-stash/pass-b-chat-v4.1.html public/instruments/pass-b-chat-v4.1.html
  echo "restored stashed instrument $(wc -c < public/instruments/pass-b-chat-v4.1.html)"
fi
python3 <<'PY'
from pathlib import Path
Path("components").mkdir(parents=True, exist_ok=True)
Path("components/AiInstrument.tsx").write_text(r'''"use client";

import { useEffect, useRef } from "react";

const HEIGHT_MSG = "typedb-passb-height";

export function AiInstrument() {
  const frameRef = useRef<HTMLIFrameElement>(null);

  useEffect(() => {
    const applyHeight = (height: number) => {
      const frame = frameRef.current;
      if (!frame || !Number.isFinite(height) || height < 400) return;
      frame.style.height = `${Math.ceil(height)}px`;
    };

    const onMessage = (event: MessageEvent) => {
      const data = event.data;
      if (!data || data.type !== HEIGHT_MSG) return;
      applyHeight(Number(data.height));
    };

    const prepareEmbedField = () => {
      const frame = frameRef.current;
      const doc = frame?.contentDocument;
      if (!doc) return;
      doc.documentElement.style.background = "transparent";
      doc.body.style.background = "transparent";
      doc.documentElement.style.colorScheme = "normal";
      // Author display:flex on .eyebrow-wrap beats [hidden]. Force the iframe pill off.
      let hide = doc.getElementById("typedb-embed-hide");
      if (!hide) {
        hide = doc.createElement("style");
        hide.id = "typedb-embed-hide";
        hide.textContent = `
          .eyebrow-wrap, .stage > h2, .dots { display: none !important; }
          .typeql-band { height: 228px; }
          .typeql-grid { height: 180px; min-height: 180px; }
          .typeql-pane { height: 180px; overflow: hidden; }
        `;
        doc.head.appendChild(hide);
      }
      const stage = doc.getElementById("shot");
      if (stage) {
        stage.style.background = "transparent";
        stage.style.paddingTop = "12px";
      }
    };

    const syncFromDocument = () => {
      const frame = frameRef.current;
      if (!frame) return;
      try {
        prepareEmbedField();
        const stage = frame.contentDocument?.getElementById("shot");
        if (!stage) return;
        applyHeight(stage.getBoundingClientRect().height);
      } catch {
        // cross-origin: height arrives via postMessage
      }
    };

    window.addEventListener("message", onMessage);
    const frame = frameRef.current;
    frame?.addEventListener("load", syncFromDocument);
    syncFromDocument();
    return () => {
      window.removeEventListener("message", onMessage);
      frame?.removeEventListener("load", syncFromDocument);
    };
  }, []);

  return (
    <figure className="passb-iframe-wrap" data-s2="pass-b-chat-v4.1">
      <iframe
        ref={frameRef}
        title="Connected context — pass-b-chat-v4.1"
        src="/instruments/pass-b-chat-v4.1.html"
        className="passb-iframe"
        loading="eager"
        scrolling="no"
      />
    </figure>
  );
}
''')
print("overlaid components/AiInstrument.tsx", Path("components/AiInstrument.tsx").stat().st_size)
PY
python3 <<'PY'
from pathlib import Path
Path("components").mkdir(parents=True, exist_ok=True)
Path("components/AiSystems.tsx").write_text(r'''import { copy } from "@/lib/copy";
import { AiInstrument } from "./AiInstrument";

export function AiSystems() {
  return (
    <section className="section section-proof" id="ai-systems">
      <div className="wrap">
        <div className="ai-systems-head">
          <p className="eyebrow">{copy.ai.kicker}</p>
          <h2 className="section-title">{copy.ai.h2}</h2>
        </div>
        <AiInstrument />
        <ol className="ai-pillars">
          {copy.ai.pillars.map((pillar) => (
            <li key={pillar.index}>
              <span>{pillar.index}</span>
              <div>
                <h3>{pillar.title}</h3>
                <p>{pillar.body}</p>
              </div>
            </li>
          ))}
        </ol>
        <h3 className="ai-audit-title">{copy.ai.auditH3}</h3>
        <p className="lede">{copy.ai.auditBody}</p>
        <p className="lede">{copy.ai.auditBody2}</p>
        <dl className="audit-metrics">
          {copy.ai.metrics.map((item) => (
            <div key={item.value}>
              <dt>{item.value}</dt>
              <dd>{item.label}</dd>
            </div>
          ))}
        </dl>
      </div>
    </section>
  );
}
''')
print("overlaid components/AiSystems.tsx", Path("components/AiSystems.tsx").stat().st_size)

globals_css = Path("app/globals.css")
if globals_css.is_file():
    text = globals_css.read_text()
    old = """.section-proof {
  background: var(--deep);
  border-block: 1px solid var(--line);
}"""
    new = """.section-proof {
  background: transparent;
  border-block: none;
}

#neo4j.section-proof {
  background: var(--deep);
  border-block: 1px solid var(--line);
}"""
    if old in text:
        globals_css.write_text(text.replace(old, new, 1))
        print("patched app/globals.css section-proof wash")
    else:
        print("globals.css section-proof already patched or missing")
PY
python3 <<'PY'
from pathlib import Path
Path('app').mkdir(parents=True, exist_ok=True)
Path('app/page.tsx').write_text(r'''import { Footer } from "@/components/Footer";
import { Header } from "@/components/Header";
import { Hero } from "@/components/Hero";
import { LogoBar } from "@/components/LogoBar";
import { AiSystems } from "@/components/AiSystems";
import { Analytics } from "@/components/Analytics";
import { Neo4jStrip } from "@/components/Neo4jStrip";
import { StartPath } from "@/components/StartPath";
import { Suite } from "@/components/Suite";
import { Blog } from "@/components/Blog";

export default async function Home() {
  return (
    <>
      <Header />
      <main>
        <Hero />
        <LogoBar />
        <AiSystems />
        <Analytics />
        <Neo4jStrip />
        <Suite />
        <StartPath />
        <Blog />
      </main>
      <Footer />
    </>
  );
}
''')
print('overlaid app/page.tsx', Path('app/page.tsx').stat().st_size)
Path('lib').mkdir(parents=True, exist_ok=True)
Path('lib/urls.ts').write_text(r'''export const urls = {
  home: "https://typedb.com/",
  docs: "https://typedb.com/docs",
  cloud: "https://typedb.com/cloud",
  install: "https://typedb.com/docs/home/install/",
  communityEdition: "https://typedb.com/docs/home/install/ce/",
  studio: "https://studio.typedb.com/",
  typeql: "https://typedb.com/docs/core-concepts/typeql/",
  blog: "https://typedb.com/blog",
  github: "https://github.com/typedb/typedb",
  discord: "https://typedb.com/discord",
  whatIs: "https://typedb.com/docs/home/what-is-typedb",
  editions: "https://typedb.com/editions",
  agentic: "https://typedb.com/use-cases/agentic-systems",
  cti: "https://typedb.com/use-cases/cyber-threat-intelligence",
  // GAP: typedb.com/use-cases/life-sciences 404 (2026-09-09). Do not invent a page.
  financialIntel: "https://typedb.com/use-cases/financial-intelligence",
  // GAP: typedb.com/use-cases/industrial 404 (2026-09-09). Do not invent a page.
  dataLineage: "https://typedb.com/use-cases/lineage",
  knowledgeGraphs: "https://typedb.com/use-cases/knowledge-graphs",
  graphDocs: "https://typedb.com/docs/use-cases/graph/",
  originRepo: "https://github.com/originsciences/epigraph",
  brgmBlog: "https://typedb.com/blog/from-geoscience-to-decision-making",
  useCasesIndex: "https://typedb.com/docs/use-cases",
  useCasesRobotics: "https://typedb.com/docs/use-cases/robotics",
  useCasesIam: "https://typedb.com/docs/use-cases/iam",
  useCasesCyber: "https://typedb.com/docs/use-cases/cybersecurity",
  useCasesAi: "https://typedb.com/docs/use-cases/ai",
  useCasesPage: "/use-cases",
  linkedin: "https://www.linkedin.com/company/typedb",
  twitter: "https://twitter.com/TypeDB_",
  newsletter: "https://typedb.com/?dialog=newsletter",
  blogPosts: {
    llmBench: "https://typedb.com/blog/benchmarking-llm-query-generation-across-sql-cypher-and-typeql",
    givenClause: "https://typedb.com/blog/preventing-typeql-injection-with-typedbs-new-given-clause",
    schemaStrict: "https://typedb.com/blog/how-strict-should-your-schema-be",
    vectorSearch: "https://typedb.com/blog/previewing-native-vector-search-to-typedb",
  },
} as const;
''')
print('overlaid lib/urls.ts', Path('lib/urls.ts').stat().st_size)
Path('lib').mkdir(parents=True, exist_ok=True)
Path('lib/copy.ts').write_text(r'''import { urls } from "./urls";

export const copy = {
  meta: {
    title: "TypeDB — The Knowledge Engine for AI Reasoning",
    description:
      "Ground your AI in a typed knowledge graph that encodes your domain, enforces its rules, and lets systems reason over facts instead of loose text.",
  },
  header: {
    links: [
      { label: "Docs", href: urls.docs },
      { label: "Cloud", href: urls.cloud },
      { label: "Studio", href: urls.studio },
      { label: "Use cases", href: urls.useCasesPage },
      { label: "Blog", href: urls.blog },
      { label: "GitHub", href: urls.github },
    ],
    primary: { label: "Try Cloud", href: urls.cloud },
  },
  hero: {
    kicker: "Knowledge Engine",
    h1: "The Knowledge Engine for AI Reasoning",
    sub: "Ground your AI in a typed knowledge graph that encodes your domain, enforces its rules, and lets systems reason over facts instead of loose text.",
    primary: { label: "Try Cloud", href: urls.cloud },
    secondary: { label: "Docs", href: urls.docs },
  },
  ai: {
    kicker: "AI Systems",
    h2: "Connected context across your data",
    pillars: [
      {
        index: "01",
        title: "Semantic Knowledge Graphs",
        body: "Standard graphs store untyped nodes and edges. TypeDB models entities, relations, and roles with a rich type system, so your knowledge graph matches the real structure of your domain instead of a generic property bag.",
      },
      {
        index: "02",
        title: "Logical Inference",
        body: "Most databases only return what you inserted. TypeDB adds a logical layer: rules and constraints that infer new facts, uncover hidden relationships, and continuously validate your data against the semantics of your schema.",
      },
      {
        index: "03",
        title: "Explainable AI",
        body: "LLMs and vector search offer powerful pattern matching, but weak guarantees. With TypeDB, every conclusion is backed by an explicit chain of entities, relations, and rules — giving you an inspectable reasoning trace for every answer.",
      },
    ],
    auditH3: "Auditability as structure.",
    auditBody:
      "When an AI system answers a question or triggers an action on top of TypeDB, it does so over an explicit network of entities, relations, and rules. The reasoning path is stored as data: which facts were used, which rules fired, and how intermediate conclusions were derived.",
    auditBody2:
      "Alternative hypotheses can be compared, challenged, and re-run. The basis for any decision is examinable in terms of schema, constraints, and logical steps, not just token probabilities or embedding distances.",
    metrics: [
      { value: "Sub-ms", label: "Schema and constraint checks" },
      { value: "1,000+", label: "tx/sec reads & writes" },
      { value: "100 GB–4 TB", label: "Knowledge graph sizes" },
      { value: "ACID", label: "Compliant with persistence" },
    ],
  },
  analytics: {
    kicker: "Knowledge Graph Analytics",
    h2: "One database. Native reasoning across workloads.",
    lede: "The same reasoning engine that guides AI systems also drives knowledge graph analytics.",
    cards: [
      {
        id: "life-sciences",
        index: "01",
        title: "Life sciences & research",
        body: "Model biology, compounds, and clinical evidence as a unified knowledge graph. Let inference surface non-obvious mechanisms, repurposing opportunities, and safety risks across your R&D pipeline.",
        href: "#",
        hrefLabel: "Read more",
      },
      {
        id: "financial-crime",
        index: "02",
        title: "Financial crime & risk",
        body: "Capture complex ownership structures, transactions, and risk signals as typed relations. Use rules to codify regulatory logic and expose higher-order patterns that simple link analysis misses.",
        href: urls.financialIntel,
        hrefLabel: "Read more",
      },
      {
        id: "cti",
        index: "03",
        title: "Cyber threat intelligence",
        body: "Represent actors, indicators, campaigns, and TTPs in one graph. Inference connects partial observations into coherent hypotheses, helping analysts move from isolated alerts to explainable threat stories.",
        href: urls.cti,
        hrefLabel: "Read more",
      },
      {
        id: "industrial",
        index: "04",
        title: "Industrial & IoT systems",
        body: "Unify assets, telemetry, maintenance, and process models. Use TypeDB to reason over dependencies, impact paths, and failure modes across large, heterogeneous environments.",
        href: "#",
        hrefLabel: "Read more",
      },
      {
        id: "lineage",
        index: "05",
        title: "Data lineage & governance",
        body: "Track how data is produced, transformed, combined, and consumed across your stack. Typed relations and rules enforce policies and help auditors trace every decision back to its sources.",
        href: urls.dataLineage,
        hrefLabel: "Read more",
      },
      {
        id: "enterprise-kg",
        index: "06",
        title: "Enterprise knowledge graph",
        body: "Build a single, consistent knowledge backbone that connects products, customers, contracts, and processes. Power search, analytics, and AI from one governed source of truth.",
        href: urls.knowledgeGraphs,
        hrefLabel: "Read more",
      },
    ],
  },
  neo4j: {
    question: "Migrating from Neo4j?",
    body: "Level up with schema, semantics, and native inference.",
    href: urls.graphDocs,
    hrefLabel: "Explore the docs",
  },
  s1: {
    h2: "Context infrastructure",
    tabs: {
      haveGraph: {
        id: "have-graph",
        label: "We've got a graph",
        job: "If you already run a property graph, roles and constraints often still live in application code. When those rules drift from the stored edges, multi-step work returns answers that look fine and are wrong. Updating that context by hand does not keep up at scale.",
      },
      noGraph: {
        id: "no-graph",
        label: "Still in docs and prompts",
        job: "If the domain map still lives in docs, prompts, and application code, someone updates it after the fact. Multi-step inference then runs on a map that lags the product. At scale that lag is the failure.",
      },
    },
    stages: {
      retrieve: { index: "01", label: "Retrieve" },
      ground: { index: "02", label: "Ground" },
      reason: { index: "03", label: "Reason" },
      persist: { index: "04", label: "Persist" },
    },
    haveGraph: {
      retrieve: {
        title: "The question hits the stored walk",
        body: "Who owns the typedb repository?",
      },
      ground: {
        title: "The edge is already there",
        body: "Alice and typedb are nodes. OWNS is a binary edge. Who is owner is still a convention in application code.",
      },
      reason: {
        title: "A longer walk can still be wrong",
        body: "Roles are not on the edge. Multi-step work can return a wrong owner and still look well-formed.",
      },
      persist: {
        title: "TypeDB writes the typed fact",
        body: "resource-ownership plays owner and resource. A write that misses a role fails in the database.",
      },
    },
    noGraph: {
      retrieve: {
        title: "The same question still needs an answer",
        body: "Who owns the typedb repository?",
      },
      ground: {
        title: "The map is reconstructed",
        body: "Alice, the repository, and who owns it live in docs, prompts, and application code.",
      },
      reason: {
        title: "Inference runs on a lagging map",
        body: "Someone updates that map after the fact. Multi-step work then reasons over a world that is already stale.",
      },
      persist: {
        title: "TypeDB holds the write",
        body: "The same facts become types. A write that does not fit the schema fails here.",
      },
    },
    sharedNote:
      "Alice, the typedb repository, and resource-ownership are the live homepage teaching example. They are not a customer.",
  },
  s2: {
    h2: "What changes when meaning lives in the database",
    lede: "Three consequences of putting domain meaning in TypeDB.",
    props: [
      {
        title: "Schema is the type system",
        body: "Entities, relations, and attributes are types. A write is an instance of those types, not a hint left in application code.",
      },
      {
        title: "Relations can be n-party",
        body: "A fact can carry more than two roles. Employment can link employee, employer, and the project they work on as one relation.",
      },
      {
        title: "The database enforces",
        body: "A write or query that breaks a role or type fails with an error. TypeDB does not suggest a repair. Agents can introspect the schema.",
      },
    ],
    graphic: {
      title: "Ingest, update, enforce",
      lede: "The same type system is production.",
      ingest: {
        label: "Ingest",
        body: "Schema is the type system. Writes arrive as instances: entities, n-party relations, attributes.",
      },
      update: {
        label: "Update",
        body: "Production is the model. A change is another write. Subtype queries still see the specialized instance.",
      },
      enforce: {
        label: "Enforce",
        body: "TypeDB enforces. It does not suggest. A role or type break is a query error. Agents introspect the schema instead of inventing the join.",
      },
    },
  },
  s3: {
    h2: "What problem are you trying to hold in one model?",
    lede: "Four problems teams already have. Each one is a typed model in TypeDB.",
    items: [
      {
        id: "code-graph",
        industry: "Software",
        title: "Context drift in a growing codebase",
        job: "When a codebase is large and sessions are long, context goes stale and patterns drift. Coding agents then ship against an invented map of the code.",
        with: "A code graph in TypeDB keeps functions, tests, and the relations between them as a typed, schema-enforced source of truth. Agents query that model instead of walking untyped edges.",
        href: urls.docs,
        hrefLabel: "TypeDB docs",
      },
      {
        id: "agentic",
        industry: "Agentic systems",
        title: "Operational knowledge agents can query",
        job: "Agents need a shared model of the domain they write to. Retrieval returns neighbors. The agent still invents which things can connect.",
        with: "TypeDB stores entities, relations, and roles under a schema. Invalid writes fail. This page does not claim that agents never invent facts.",
        href: urls.agentic,
        hrefLabel: "Agentic systems",
      },
      {
        id: "cti",
        industry: "Cybersecurity",
        title: "Threats as a connected model",
        job: "Analysts need to ask how actors, campaigns, indicators, and hosts relate, not only list events.",
        with: "TypeDB models those entities and relations under a schema. Official TypeDB pages already name cyber threat intelligence. This page does not name a CTI customer.",
        href: urls.cti,
        hrefLabel: "Cyber threat intelligence",
      },
      {
        id: "decision",
        industry: "Decision support",
        title: "A domain model people can query as it changes",
        job: "Teams aiding decisions over a physical or regulatory domain need one model of sites, constraints, and measurements.",
        with: "TypeDB holds that model as typed relations. A TypeDB case write-up describes this pattern at France’s geological survey. Christian Iasio is credited on the project side. BRGM’s institutional page does not name TypeDB.",
        href: urls.brgmBlog,
        hrefLabel: "TypeDB blog",
      },
    ],
  },
  s4: {
    sentence: "Structure that is not enforced is only a suggestion.",
    marks: ["Structure", "enforced", "suggestion"],
  },
  s5: {
    kicker: "Suite",
    h2: "TypeDB suite",
    lede: "Database, Cloud, Studio, and TypeQL.",
    products: [
      {
        id: "database",
        label: "Database",
        title: "The database",
        body: "The engine holds the schema. Relations have named roles. A fact can connect more than two things. Schema is enforced on write.",
        href: urls.install,
        hrefLabel: "Install TypeDB",
      },
      {
        id: "cloud",
        label: "Cloud",
        title: "Managed TypeDB",
        body: "Fully managed TypeDB on AWS or GCP. Open an instance and work the same schema.",
        href: urls.cloud,
        hrefLabel: "TypeDB Cloud",
      },
      {
        id: "studio",
        label: "Studio",
        title: "Web and desktop environment",
        body: "Studio is the official environment on that database. Define types and run TypeQL against the live schema.",
        href: urls.studio,
        hrefLabel: "TypeDB Studio",
      },
      {
        id: "typeql",
        label: "TypeQL",
        title: "The query language",
        body: "TypeQL is how the schema and the questions are written. Community Edition runs the same engine.",
        href: urls.typeql,
        hrefLabel: "TypeQL docs",
      },
    ],
    typeql: `define
  user sub entity;
  repository sub entity;
  resource-ownership sub relation,
    relates owner,
    relates resource;
  user plays resource-ownership:owner;
  repository plays resource-ownership:resource;`,
  },
  s6: {
    h2: "For Developers",
    lede: "Start in minutes. Community Edition is fully featured, free forever.",
    steps: [
      {
        n: "01",
        label: "Open TypeDB Cloud",
        body: "Create a managed database on AWS or GCP. No local install.",
        href: urls.cloud,
      },
      {
        n: "02",
        label: "Install Community Edition",
        body: "Run the same engine locally from the install page.",
        href: urls.communityEdition,
      },
      {
        n: "03",
        label: "Read TypeQL in the docs",
        body: "Schema, roles, and drivers before you write application code.",
        href: urls.typeql,
      },
    ],
  },
  metrics: {
    h2: "What we can source today",
    lede: "Numbers from the public typedb/typedb GitHub repository. Community size is omitted. This page does not invent it.",
    items: [
      {
        value: "4,443",
        label: "GitHub stars",
        href: urls.github,
        // Source: GET https://api.github.com/repos/typedb/typedb 2026-09-07 stargazers_count
      },
      {
        value: "372",
        label: "GitHub forks",
        href: urls.github,
        // Source: GET https://api.github.com/repos/typedb/typedb 2026-09-07 forks_count
      },
      {
        value: "2016",
        label: "Repository created",
        href: urls.github,
        // Source: GET https://api.github.com/repos/typedb/typedb created_at 2016-07-11
      },
    ],
  },
  industries: {
    h2: "Which domains does TypeDB already document?",
    lede: "Cribbed from the TypeDB use-cases docs. Each card links to that docs page. Graph and hypergraph index entries had no stable docs URL at write time, so they are omitted.",
    items: [
      {
        id: "robotics",
        title: "Robotics",
        body: "TypeDB models heterogeneous worlds, datasets, and interactions. The official robotics example is robotic navigation of a floorplan. Docs credit a real-world usage developed by Joris Sijs at TNO.",
        href: urls.useCasesRobotics,
        hrefLabel: "Robotics docs",
      },
      {
        id: "iam",
        title: "IAM",
        body: "TypeDB models identity, resources, and permission systems. The documented schema enforces permissions, ownership, and segregation of duties across subjects, objects, and actions.",
        href: urls.useCasesIam,
        hrefLabel: "IAM docs",
      },
      {
        id: "cybersecurity",
        title: "Cybersecurity",
        body: "The polymorphic model fits cyber threat intelligence. Official TypeDB CTI work implements STIX 2.1: threat actors, campaigns, indicators, and infrastructure as typed relations.",
        href: urls.useCasesCyber,
        hrefLabel: "Cybersecurity docs",
      },
      {
        id: "ai",
        title: "AI",
        body: "Docs describe TypeDB’s schema as context for AI applications: unstructured sources written into a typed graph, prompt-guided TypeQL, and the TypeDB MCP Server.",
        href: urls.useCasesAi,
        hrefLabel: "AI docs",
      },
    ],
    more: { label: "All cribbed use cases", href: urls.useCasesPage },
    proof: {
      h2: "Two projects we can name",
      lede: "Proof we already have. Not the problems above.",
      items: [
        {
          name: "Origin Sciences",
          kind: "Research platform",
          body: "Origin Sciences uses TypeDB for the knowledge graph, and DuckDB/Parquet for dense matrix data. TypeDB did not run that workload alone.",
          href: urls.originRepo,
          hrefLabel: "EpiGraph on GitHub",
        },
        {
          name: "BRGM / ThermEcoWat",
          kind: "Decision-aiding platform",
          body: "TypeDB’s case write-up describes ThermEcoWat, a decision-aiding platform at France’s geological survey (BRGM). Christian Iasio is credited on the project side. BRGM’s institutional page does not name TypeDB.",
          href: urls.brgmBlog,
          hrefLabel: "TypeDB blog",
        },
      ],
    },
  },
  close: {
    h2: "Start on one of the three paths",
    lede: "Cloud, Community Edition, or the docs. The footer has the rest of the live site.",
  },
  useCasesPage: {
    title: "TypeDB use cases",
    h2: "Use cases cribbed from the docs",
    lede: "Short versions of the official TypeDB use-case docs. Each one links to the full page. This is not a new product claim.",
  },
  usage: {
    items: [
      { id: "queries", label: "Queries" },
      { id: "schemaChecks", label: "Schema checks" },
      { id: "writes", label: "Writes" },
    ],
  },
  logos: {
    eyebrow: "Trusted by teams at",
    names: [
      "Origin Sciences",
      "BRGM",
      "TNO",
      "Bayer",
      "Roche",
      "AstraZeneca",
      "GSK",
      "National Archives",
      "Bank of Canada",
      "Carleton University",
    ],
  },
  blog: {
    h2: "From the blog",
    more: { label: "Read more in blog", href: urls.blog },
    posts: [
      {
        title: "Benchmarking LLM query generation across SQL, Cypher and TypeQL",
        date: "8 Sep 2026",
        lede: "Two models, 42 questions, MySQL, Neo4j, and TypeDB. How context and retries change what the generated query gets right.",
        href: urls.blogPosts.llmBench,
      },
      {
        title: "Preventing TypeQL injection with TypeDB's new 'given' clause",
        date: "3 Sep 2026",
        lede: "How query injection works, and how TypeQL parameters keep values out of the query string.",
        href: urls.blogPosts.givenClause,
      },
      {
        title: "How strict should your schema be?",
        date: "25 Aug 2026",
        lede: "Type safety in TypeDB as a spectrum, from a thin schema to one that rejects invalid states.",
        href: urls.blogPosts.schemaStrict,
      },
      {
        title: "Previewing the new native vector search",
        date: "18 Aug 2026",
        lede: "Embeddings as a native TypeDB datatype, queried with cosine similarity in the same database.",
        href: urls.blogPosts.vectorSearch,
      },
    ],
  },
  footer: {
    columns: [
      {
        title: "Product",
        links: [
          { label: "What is TypeDB", href: urls.whatIs },
          { label: "TypeDB Cloud", href: urls.cloud },
          { label: "TypeDB Studio", href: urls.studio },
          { label: "Community Edition", href: urls.communityEdition },
          { label: "Editions", href: urls.editions },
        ],
      },
      {
        title: "Docs",
        links: [
          { label: "Documentation", href: urls.docs },
          { label: "TypeQL", href: urls.typeql },
          { label: "Install", href: urls.install },
          { label: "Use cases", href: urls.useCasesPage },
          { label: "Use-case docs", href: urls.useCasesIndex },
        ],
      },
      {
        title: "Community",
        links: [
          { label: "GitHub", href: urls.github },
          { label: "Discord", href: urls.discord },
          { label: "Blog", href: urls.blog },
        ],
      },
      {
        title: "TypeDB",
        links: [{ label: "typedb.com", href: urls.home }],
      },
    ],
    socials: [
      { label: "GitHub", href: urls.github },
      { label: "Discord", href: urls.discord },
      { label: "LinkedIn", href: urls.linkedin },
      { label: "X", href: urls.twitter },
    ],
    subscribe: {
      label: "Product updates and company news",
      placeholder: "Email",
      submit: "Subscribe",
      action: urls.newsletter,
    },
  },
} as const;
''')
print('overlaid lib/copy.ts', Path('lib/copy.ts').stat().st_size)
Path('components').mkdir(parents=True, exist_ok=True)
Path('components/Footer.tsx').write_text(r'''import Link from "next/link";
import { copy } from "@/lib/copy";
import { urls } from "@/lib/urls";

export function Footer() {
  return (
    <footer className="site-footer">
      <div className="wrap">
        <div className="footer-grid">
          {copy.footer.columns.map((column) => (
            <nav key={column.title} aria-label={column.title}>
              <p className="footer-col-title">{column.title}</p>
              {column.links.map((link) =>
                link.href.startsWith("/") ? (
                  <Link key={link.href + link.label} href={link.href}>
                    {link.label}
                  </Link>
                ) : (
                  <a key={link.href + link.label} href={link.href} rel="noreferrer">
                    {link.label}
                  </a>
                ),
              )}
            </nav>
          ))}
        </div>
        <div className="footer-tools">
          <nav className="footer-socials" aria-label="TypeDB on the web">
            {copy.footer.socials.map((item) => (
              <a key={item.href} href={item.href} rel="noreferrer">
                {item.label}
              </a>
            ))}
          </nav>
          <form className="footer-subscribe" action={urls.home} method="get">
            <input type="hidden" name="dialog" value="newsletter" />
            <label htmlFor="footer-email">{copy.footer.subscribe.label}</label>
            <div className="footer-subscribe-row">
              <input
                id="footer-email"
                type="email"
                name="email"
                autoComplete="email"
                required
                placeholder={copy.footer.subscribe.placeholder}
              />
              <button type="submit">{copy.footer.subscribe.submit}</button>
            </div>
          </form>
        </div>
      </div>
    </footer>
  );
}
''')
print('overlaid components/Footer.tsx', Path('components/Footer.tsx').stat().st_size)
Path('components').mkdir(parents=True, exist_ok=True)
Path('components/UsageCounters.tsx').write_text(r'''"use client";

import { useEffect, useRef, useState } from "react";
import { copy } from "@/lib/copy";

// Illustrative only. Not official TypeDB metrics. No live feed.
type CounterId = "queries" | "schemaChecks" | "writes";

const START: Record<CounterId, number> = {
  queries: 1_284_391,
  schemaChecks: 48_221,
  writes: 192_774,
};

const PER_SECOND: Record<CounterId, number> = {
  queries: 17,
  schemaChecks: 3,
  writes: 4,
};

function formatCount(value: number) {
  return new Intl.NumberFormat("en-GB").format(Math.floor(value));
}

export function UsageCounters() {
  const startedAt = useRef<number | null>(null);
  const [values, setValues] = useState(START);
  const sectionRef = useRef<HTMLElement>(null);

  useEffect(() => {
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (reduce) return;

    startedAt.current = Date.now();
    let frame = 0;
    let visible = true;
    const node = sectionRef.current;
    const observer = new IntersectionObserver(
      ([entry]) => {
        visible = entry.isIntersecting;
      },
      { threshold: 0.2 },
    );
    if (node) observer.observe(node);

    const tick = () => {
      if (visible && startedAt.current !== null) {
        const elapsed = (Date.now() - startedAt.current) / 1000;
        setValues({
          queries: START.queries + elapsed * PER_SECOND.queries,
          schemaChecks: START.schemaChecks + elapsed * PER_SECOND.schemaChecks,
          writes: START.writes + elapsed * PER_SECOND.writes,
        });
      }
      frame = window.requestAnimationFrame(tick);
    };
    frame = window.requestAnimationFrame(tick);
    return () => {
      window.cancelAnimationFrame(frame);
      observer.disconnect();
    };
  }, []);

  return (
    <section className="usage-strip" id="usage" ref={sectionRef} aria-label="Usage counts">
      <div className="wrap">
        <dl className="usage-counts">
          {copy.usage.items.map((item) => (
            <div key={item.id}>
              <dt>{item.label}</dt>
              <dd>{formatCount(values[item.id as CounterId])}</dd>
            </div>
          ))}
        </dl>
      </div>
    </section>
  );
}
''')
print('overlaid components/UsageCounters.tsx', Path('components/UsageCounters.tsx').stat().st_size)
Path('components').mkdir(parents=True, exist_ok=True)
Path('components/LogoBar.tsx').write_text(r'''import { copy } from "@/lib/copy";

export function LogoBar() {
  const names = [...copy.logos.names, ...copy.logos.names];

  return (
    <section className="logo-bar" id="teams" aria-label={copy.logos.eyebrow}>
      <div className="wrap">
        <p className="eyebrow">{copy.logos.eyebrow}</p>
      </div>
      <div className="logo-track-wrap">
        <ul className="logo-track">
          {names.map((name, index) => (
            <li key={`${name}-${index}`} aria-hidden={index >= copy.logos.names.length}>
              {name}
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}
''')
print('overlaid components/LogoBar.tsx', Path('components/LogoBar.tsx').stat().st_size)
Path('components').mkdir(parents=True, exist_ok=True)
Path('components/Blog.tsx').write_text(r'''import { copy } from "@/lib/copy";

export function Blog() {
  return (
    <section className="section" id="blog">
      <div className="wrap">
        <h2 className="section-title">{copy.blog.h2}</h2>
        <ul className="blog-grid">
          {copy.blog.posts.map((post) => (
            <li key={post.href}>
              <a className="blog-card" href={post.href} rel="noreferrer">
                <p className="blog-date">{post.date}</p>
                <h3>{post.title}</h3>
                <p>{post.lede}</p>
              </a>
            </li>
          ))}
        </ul>
        <p className="blog-more">
          <a href={copy.blog.more.href} rel="noreferrer">
            {copy.blog.more.label}
          </a>
        </p>
      </div>
    </section>
  );
}
''')
print('overlaid components/Blog.tsx', Path('components/Blog.tsx').stat().st_size)
Path('components').mkdir(parents=True, exist_ok=True)
Path('components/ShareGate.tsx').write_text(r'''"use client";

import { useState, useSyncExternalStore, type FormEvent, type ReactNode } from "react";

const KEY = "typedb-hp-share";
const EXPECTED = "typedb-share-10sep";

const listeners = new Set<() => void>();
let memoryOk = false;

function subscribe(onStoreChange: () => void) {
  listeners.add(onStoreChange);
  return () => {
    listeners.delete(onStoreChange);
  };
}

function emit() {
  for (const listener of listeners) {
    listener();
  }
}

function readUnlocked(): boolean {
  if (memoryOk) {
    return true;
  }
  try {
    return sessionStorage.getItem(KEY) === "1";
  } catch {
    return false;
  }
}

function serverUnlocked(): boolean {
  return false;
}

function unlock() {
  memoryOk = true;
  try {
    sessionStorage.setItem(KEY, "1");
  } catch {
    /* sessionStorage can be blocked */
  }
  emit();
}

export function ShareGate({ children }: { children: ReactNode }) {
  const unlocked = useSyncExternalStore(subscribe, readUnlocked, serverUnlocked);
  const [error, setError] = useState("");

  function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const value = String(new FormData(event.currentTarget).get("password") ?? "");
    if (value === EXPECTED) {
      unlock();
      setError("");
      return;
    }
    setError("Wrong password.");
  }

  return (
    <>
      {children}
      {unlocked ? null : (
        <div className="share-gate">
          <form className="share-gate-form" onSubmit={onSubmit}>
            <p className="share-gate-kicker">Preview</p>
            <h1>TypeDB homepage draft</h1>
            <p className="share-gate-copy">This preview is password-protected. Enter the share password.</p>
            <label htmlFor="share-password">Password</label>
            <input
              id="share-password"
              name="password"
              type="password"
              autoComplete="current-password"
              required
            />
            {error ? (
              <p className="share-gate-error" role="alert">
                {error}
              </p>
            ) : null}
            <button type="submit">Open preview</button>
          </form>
        </div>
      )}
    </>
  );
}
''')
print('overlaid components/ShareGate.tsx', Path('components/ShareGate.tsx').stat().st_size)
Path('app').mkdir(parents=True, exist_ok=True)
Path('app/layout.tsx').write_text(r'''import type { Metadata } from "next";
import { FontFaces } from "@/components/FontFaces";
import { FreezeGate } from "@/components/FreezeGate";
import { PageBackground } from "@/components/PageBackground";
import { ShareGate } from "@/components/ShareGate";
import { copy } from "@/lib/copy";
import { darkmode, monaco } from "./fonts";
import "./fonts.css";
import "./globals.css";
import "./lock.css";
import "./marks.css";

export const metadata: Metadata = {
  title: copy.meta.title,
  description: copy.meta.description,
  robots: {
    index: false,
    follow: false,
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={`${darkmode.variable} ${monaco.variable}`}>
      <body>
        <FontFaces />
        <FreezeGate />
        <PageBackground />
        <ShareGate>{children}</ShareGate>
      </body>
    </html>
  );
}
''')
print('overlaid app/layout.tsx', Path('app/layout.tsx').stat().st_size)
PY
# --- pm-feedback-10sep-overlays ---
python3 <<'PY'
from pathlib import Path
import base64

Path("app/marks.css").write_text(r'''/* Daniel marks on PR3 — last-loaded so lock.css does not win. */

#ai-systems,
#ai-systems.section-proof,
#suite.section-proof,
.section-proof:not(#neo4j) {
  background: transparent;
  border-block: none;
}

#ai-systems.section-proof:has(.passb-iframe-wrap) {
  padding-top: 36px;
}

.ai-systems-head {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin: 0 0 8px;
  text-align: center;
}

.ai-systems-head .section-title {
  max-width: none;
  margin: 0;
  font-size: clamp(32px, 4vw, 38px);
  font-weight: 520;
  letter-spacing: -0.025em;
  line-height: 1.15;
}

.passb-iframe-wrap {
  width: 100%;
  max-width: 100%;
  margin: 0;
  margin-left: 0;
  overflow: hidden;
  background: transparent;
}

.passb-iframe {
  display: block;
  width: 100%;
  height: 920px;
  border: 0;
  overflow: hidden;
  background: transparent;
  color-scheme: normal;
}

@media (max-width: 768px) {
  .passb-iframe {
    height: 980px;
  }
}

.ai-pillars {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 16px;
  margin: 0 0 40px;
  padding: 0;
  list-style: none;
}

.ai-pillars li {
  display: grid;
  grid-template-columns: 36px 1fr;
  gap: 14px;
  min-height: 100%;
  padding: 22px 20px 20px;
  border: 1px solid var(--raised);
  border-radius: 8px;
  background: #12101d;
}

.ai-pillars span {
  color: #01e870;
  font-family: var(--font-family-code);
  font-size: 13px;
}

.ai-pillars h3 {
  margin: 0 0 8px;
  font-size: 18px;
  font-weight: 500;
}

.ai-pillars p {
  margin: 0;
  max-width: none;
  color: var(--mute);
  font-size: 15px;
}

.ai-audit {
  display: grid;
  grid-template-columns: minmax(0, 1.15fr) minmax(16rem, 20rem);
  gap: 28px 64px;
  align-items: start;
  margin-top: 8px;
}

.ai-audit-title {
  margin: 0 0 12px;
  font-size: clamp(22px, 3vw, 30px);
  font-weight: 500;
}

.ai-audit-copy .lede + .lede {
  margin-top: 16px;
}

.audit-metrics {
  display: grid;
  grid-template-columns: 1fr;
  gap: 0;
  max-width: none;
  margin: 0;
  padding: 0;
  border-block: 1px solid color-mix(in srgb, #01e870 32%, #2a2a36);
}

.audit-metrics div {
  display: grid;
  grid-template-columns: minmax(7rem, 11rem) 1fr;
  gap: 16px;
  align-items: baseline;
  padding: 18px 0;
  text-align: left;
  border-bottom: 1px solid color-mix(in srgb, #01e870 32%, #2a2a36);
}

.audit-metrics div:last-child {
  border-bottom: 0;
}

.audit-metrics dt {
  margin: 0;
  color: var(--ink);
  font-size: clamp(22px, 2.5vw, 32px);
  font-weight: 600;
  letter-spacing: -0.03em;
  line-height: 1.15;
}

.audit-metrics dd {
  margin: 0;
  color: var(--mute-2);
  font-size: 14px;
  line-height: 1.35;
}

.section-proof {
  background: transparent;
  border-block: none;
}

#suite.section-proof {
  background: transparent;
  border-block: none;
}

#analytics,
#neo4j,
#neo4j.section-proof {
  background: #f3f3f3;
}

#neo4j.section-proof {
  border-block: none;
}

#analytics .section-title,
#neo4j .neo4j-question {
  color: #151322;
}

#analytics .lede,
#neo4j .lede {
  color: #1a182a;
}

.hero.is-pack {
  align-items: center;
  min-height: auto;
  padding: 72px 0 56px;
  text-align: center;
}

.hero.is-pack .hero-copy {
  max-width: 46rem;
  padding: 0;
}

.hero.is-pack h1 {
  max-width: 18ch;
  margin-inline: auto;
}

.hero.is-pack .hero-sub {
  margin-inline: auto;
}

.hero.is-pack .hero-actions {
  justify-content: center;
}

.analytics-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 16px;
  margin: 36px 0 0;
  padding: 0;
  list-style: none;
}

.analytics-card {
  display: flex;
  flex-direction: column;
  min-height: 100%;
  padding: 22px 20px 20px;
  border: 1px solid var(--raised);
  border-radius: 8px;
  background: #12101d;
}

.analytics-card span {
  color: #01e870;
  font-family: var(--font-family-code);
  font-size: 12px;
}

.analytics-card h3 {
  margin: 10px 0 10px;
  font-size: 18px;
  font-weight: 500;
}

.analytics-card p {
  margin: 0 0 16px;
  color: var(--mute);
  font-size: 15px;
}

.analytics-card a {
  margin-top: auto;
  color: var(--ink);
  font-size: 14px;
  text-decoration: none;
}

.analytics-card a:hover {
  color: #01e870;
}

.neo4j-strip {
  display: grid;
  gap: 10px;
}

.neo4j-question {
  margin: 0;
  font-size: clamp(24px, 3vw, 34px);
  font-weight: 500;
}

.neo4j-strip a {
  color: #01e870;
  text-decoration: none;
}

@media (max-width: 900px) {
  .ai-pillars,
  .analytics-grid,
  .ai-audit {
    grid-template-columns: 1fr;
    gap: 12px;
  }

  .audit-metrics {
    margin-top: 8px;
  }

  .audit-metrics div {
    grid-template-columns: 1fr;
    gap: 4px;
  }
}

.usage-strip {
  padding: 28px 0 8px;
}

.usage-counts {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 18px;
  margin: 0;
}

.usage-counts dt {
  margin: 0 0 6px;
  color: var(--mute-2);
  font-size: 13px;
}

.usage-counts dd {
  margin: 0;
  color: var(--ink);
  font-family: var(--font-family-code);
  font-size: clamp(22px, 3vw, 32px);
  font-weight: 500;
  letter-spacing: -0.03em;
  font-variant-numeric: tabular-nums;
}

.logo-bar {
  padding: 12px 0 48px;
  overflow: hidden;
  text-align: center;
}

.logo-bar .wrap {
  display: flex;
  justify-content: center;
}

.logo-bar .eyebrow {
  margin-bottom: 18px;
  text-align: center;
}

.logo-track-wrap {
  overflow: hidden;
  mask-image: linear-gradient(90deg, transparent, #000 8%, #000 92%, transparent);
}

.logo-track {
  display: flex;
  gap: 48px;
  width: max-content;
  margin: 0;
  padding: 0;
  list-style: none;
  animation: logo-scroll 42s linear infinite;
}

.logo-track li {
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--mute);
  white-space: nowrap;
}

.logo-track img {
  display: block;
  height: 28px;
  width: auto;
  max-width: 168px;
  object-fit: contain;
  filter: brightness(0) invert(1);
  opacity: 0.86;
}

.logo-track-wrap:hover .logo-track {
  animation-play-state: paused;
}

@keyframes logo-scroll {
  from { transform: translateX(0); }
  to { transform: translateX(-50%); }
}

.blog-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
  margin: 36px 0 0;
  padding: 0;
  list-style: none;
}

.blog-card {
  display: flex;
  flex-direction: column;
  min-height: 100%;
  padding: 22px 20px 20px;
  border: 1px solid var(--raised);
  border-radius: 8px;
  background: #12101d;
  text-decoration: none;
}

.blog-date {
  margin: 0 0 10px;
  color: #01e870;
  font-family: var(--font-family-code);
  font-size: 12px;
}

.blog-card h3 {
  margin: 0 0 10px;
  font-size: 18px;
  font-weight: 500;
}

.blog-card p:last-child {
  margin: 0;
  color: var(--mute);
  font-size: 15px;
}

.blog-more {
  margin: 24px 0 0;
}

.blog-more a {
  color: #01e870;
  text-decoration: none;
}

.footer-tools {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 28px;
  align-items: end;
  margin-top: 32px;
}

.footer-socials {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
}

.footer-subscribe label {
  display: block;
  margin: 0 0 10px;
  color: var(--ink);
  font-size: 13px;
  font-weight: 500;
}

.footer-subscribe-row {
  display: flex;
  gap: 8px;
}

.footer-subscribe input {
  flex: 1;
  min-height: 40px;
  padding: 0 12px;
  border: 1px solid var(--raised);
  border-radius: 4px;
  background: #12101d;
  color: var(--ink);
  font: inherit;
  font-size: 14px;
}

.footer-subscribe button {
  min-height: 40px;
  padding: 0 14px;
  border: 0;
  border-radius: 4px;
  background: var(--accent);
  color: #041614;
  font: inherit;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
}

@media (max-width: 768px) {
  .usage-counts,
  .blog-grid,
  .footer-tools {
    grid-template-columns: 1fr;
  }

  .logo-track {
    animation: none;
    flex-wrap: wrap;
    justify-content: center;
    width: auto;
    gap: 16px 24px;
    padding: 0 20px;
  }

  .logo-track-wrap {
    mask-image: none;
  }
}

@media (prefers-reduced-motion: reduce) {
  .logo-track {
    animation: none;
    flex-wrap: wrap;
    justify-content: center;
    width: auto;
    max-width: 1120px;
    margin-inline: auto;
    padding: 0 20px;
  }
}

.share-gate {
  position: fixed;
  inset: 0;
  z-index: 80;
  display: grid;
  place-items: center;
  padding: 24px;
  background: var(--page);
}

.share-gate-form {
  width: min(28rem, 100%);
}

.share-gate-kicker {
  margin: 0 0 8px;
  color: var(--accent);
  font-size: 13px;
}

.share-gate h1 {
  margin: 0 0 16px;
  font-size: 28px;
  font-weight: 520;
  letter-spacing: -0.025em;
}

.share-gate-copy {
  margin: 0 0 20px;
  color: var(--mute);
}

.share-gate label {
  display: block;
  margin: 0 0 8px;
  font-size: 13px;
}

.share-gate input {
  width: 100%;
  min-height: 40px;
  padding: 0 12px;
  border: 1px solid var(--raised);
  border-radius: 4px;
  background: #12101d;
  color: var(--ink);
  font: inherit;
}

.share-gate-error {
  margin: 10px 0 0;
  color: var(--danger);
  font-size: 14px;
}

.share-gate button {
  margin-top: 16px;
  min-height: 40px;
  padding: 0 14px;
  border: 0;
  border-radius: 4px;
  background: var(--accent);
  color: #041614;
  font: inherit;
  font-weight: 500;
  cursor: pointer;
}
''')
print("overlaid app/marks.css", Path("app/marks.css").stat().st_size)

Path("components").mkdir(parents=True, exist_ok=True)
Path("components/Hero.tsx").write_text(r'''import { copy } from "@/lib/copy";

export function Hero() {
  return (
    <section className="hero wrap is-pack" id="top" data-hero-mobile="v1">
      <div className="hero-copy">
        <h1>{copy.hero.h1}</h1>
        <p className="hero-sub">{copy.hero.sub}</p>
        <div className="hero-actions">
          <a className="btn btn-primary" href={copy.hero.primary.href} rel="noreferrer">
            {copy.hero.primary.label}
          </a>
          <a className="btn btn-ghost" href={copy.hero.secondary.href} rel="noreferrer">
            {copy.hero.secondary.label}
          </a>
        </div>
      </div>
    </section>
  );
}
''')
print("overlaid components/Hero.tsx", Path("components/Hero.tsx").stat().st_size)

Path("components/LogoBar.tsx").write_text(r'''import { copy } from "@/lib/copy";

export function LogoBar() {
  const marks = [...copy.logos.marks, ...copy.logos.marks];

  return (
    <section className="logo-bar" id="teams" aria-label={copy.logos.eyebrow}>
      <div className="wrap">
        <p className="eyebrow">{copy.logos.eyebrow}</p>
      </div>
      <div className="logo-track-wrap">
        <ul className="logo-track">
          {marks.map((mark, index) => {
            const duplicate = index >= copy.logos.marks.length;
            return (
              <li key={`${mark.name}-${index}`} aria-hidden={duplicate}>
                <img src={mark.src} alt={duplicate ? "" : mark.name} />
              </li>
            );
          })}
        </ul>
      </div>
    </section>
  );
}
''')
print("overlaid components/LogoBar.tsx", Path("components/LogoBar.tsx").stat().st_size)

Path("components/AiSystems.tsx").write_text(r'''import { copy } from "@/lib/copy";
import { AiInstrument } from "./AiInstrument";

export function AiSystems() {
  return (
    <section className="section section-proof" id="ai-systems">
      <div className="wrap">
        <div className="ai-systems-head">
          <p className="eyebrow">{copy.ai.kicker}</p>
          <h2 className="section-title">{copy.ai.h2}</h2>
        </div>
        <AiInstrument />
        <ol className="ai-pillars">
          {copy.ai.pillars.map((pillar) => (
            <li key={pillar.index}>
              <span>{pillar.index}</span>
              <div>
                <h3>{pillar.title}</h3>
                <p>{pillar.body}</p>
              </div>
            </li>
          ))}
        </ol>
        <div className="ai-audit">
          <div className="ai-audit-copy">
            <h3 className="ai-audit-title">{copy.ai.auditH3}</h3>
            <p className="lede">{copy.ai.auditBody}</p>
            <p className="lede">{copy.ai.auditBody2}</p>
          </div>
          <dl className="audit-metrics">
            {copy.ai.metrics.map((item) => (
              <div key={item.value}>
                <dt>{item.value}</dt>
                <dd>{item.label}</dd>
              </div>
            ))}
          </dl>
        </div>
      </div>
    </section>
  );
}
''')
print("overlaid components/AiSystems.tsx", Path("components/AiSystems.tsx").stat().st_size)

copy = Path("lib/copy.ts")
text = copy.read_text()
old = r'''  logos: {
    eyebrow: "Trusted by teams at",
    names: [
      "Origin Sciences",
      "BRGM",
      "TNO",
      "Bayer",
      "Roche",
      "AstraZeneca",
      "GSK",
      "National Archives",
      "Bank of Canada",
      "Carleton University",
    ],
  },'''
new = r'''  logos: {
    eyebrow: "Trusted by teams at",
    marks: [
      { name: "TNO", src: "/logos/tno.svg" },
      { name: "Bayer", src: "/logos/bayer.svg" },
      { name: "Roche", src: "/logos/roche.svg" },
      { name: "AstraZeneca", src: "/logos/astrazeneca.svg" },
      { name: "Carleton University", src: "/logos/carleton.svg" },
    ],
  },'''
if old not in text:
    if 'src: "/logos/tno.svg"' in text:
        print("copy.ts logos already patched")
    else:
        raise SystemExit("copy.ts logos block not found")
else:
    copy.write_text(text.replace(old, new, 1))
    print("patched lib/copy.ts logos")

logo_dir = Path("public/logos")
logo_dir.mkdir(parents=True, exist_ok=True)
files = {
    "tno.svg": "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz4KPCEtLSBHZW5lcmF0b3I6IEFkb2JlIElsbHVzdHJhdG9yIDI1LjAuMSwgU1ZHIEV4cG9ydCBQbHVnLUluIC4gU1ZHIFZlcnNpb246IDYuMDAgQnVpbGQgMCkgIC0tPgo8c3ZnIHZlcnNpb249IjEuMiIgYmFzZVByb2ZpbGU9InRpbnkiIGlkPSJsYXllciIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIKCSB4PSIwcHgiIHk9IjBweCIgdmlld0JveD0iMCAwIDY1MiAxMjgiIG92ZXJmbG93PSJ2aXNpYmxlIiB4bWw6c3BhY2U9InByZXNlcnZlIj4KPGc+Cgk8cGF0aCBkPSJNMjYwLjYsODEuN2MtOC40LDAtMTUuMi02LjgtMTUuMi0xNS4yczYuOC0xNS4yLDE1LjItMTUuMnMxNS4yLDYuOCwxNS4yLDE1LjJTMjY5LjEsODEuNywyNjAuNiw4MS43IE0yNjAuNiwxNS40CgkJYy0yNS45LDAtNDYuMywxNy43LTUwLjMsNDIuMlYyOGMwLTcuNi0zLjMtMTAuOS0xMC45LTEwLjloLTI1LjZ2MzguNWwtMjEuOS0yOS44Yy00LjgtNi4zLTkuNS04LjctMTcuNC04LjdIMjEuMnYyNi4yCgkJYzAsNy41LDMuMiwxMC43LDEwLjcsMTAuN2gxN3Y1MC45YzAsNy42LDMuMywxMC45LDEwLjksMTAuOWgyNy44VjU0SDExMXY1MC45YzAsNy42LDMuMywxMC45LDEwLjksMTAuOWgyNS43Vjc3LjNsMjEuOSwyOS44CgkJYzQuOCw2LjMsOS41LDguNywxNy40LDguN2gyMy42Vjc1LjZjNCwyNC43LDIzLjksNDEuOCw1MC4zLDQxLjhjMjguOSwwLDUxLjEtMjIuMiw1MS4xLTUxLjFDMzExLjcsMzYuOCwyOTAuMywxNS40LDI2MC42LDE1LjQiLz4KCTxwYXRoIGQ9Ik00ODMuNiw5N2MwLjQtNS4yLDMuMy04LjEsNy4zLTguMWM0LjYsMCw3LjMsMi44LDcuNSw4LjFINDgzLjZ6IE00ODMuNCwxMDEuM2gyMi4zdi0xLjFjMC0xMC4xLTUuOC0xNi4zLTE0LjgtMTYuMwoJCWMtOC44LDAtMTQuOSw2LjYtMTQuOSwxNi41czYsMTYuMywxNS4xLDE2LjNjNy4xLDAsMTIuMS0zLjUsMTQuMy05LjhsLTYuNy0wLjdjLTEuMSwzLjQtMy45LDUuMy03LjMsNS4zYy00LjksMC04LTMuNi04LTkuOVYxMDEuMwoJCXogTTQ3Ni4yLDczLjdjLTEuOS0wLjQtMy45LTAuNS02LTAuNWMtNi44LDAtMTAsMy41LTEwLDExdjAuNmgtNS4xdjQuOGg1LjF2MjYuM2g2LjhWODkuNmg3LjR2LTQuOEg0Njd2LTAuOQoJCWMwLTMuOCwxLjUtNS41LDUuMS01LjVjMSwwLDIuNCwwLjEsNC4xLDAuNFY3My43eiBNNDQyLjQsMTE1LjhoNy4xVjg0LjdoLTcuMVYxMTUuOHogTTQ0Mi40LDc5LjZoNy4xdi01LjhoLTcuMVY3OS42egoJCSBNNDI1LjMsMTE1LjhoNy4xdi00MmgtNy4xVjExNS44eiBNNDA3LjIsODRjLTAuNi0wLjEtMS4xLTAuMS0xLjYtMC4xYy00LjQsMC03LjIsMi41LTguOCw3LjZ2LTYuN2gtNi4zdjMxLjFoN3YtMTUuNAoJCWMwLTYuMSwzLjMtOS44LDguMy05LjhjMC4zLDAsMC44LDAsMS41LDAuMUw0MDcuMiw4NEw0MDcuMiw4NHogTTM2OS45LDg5YzQuNSwwLDcuNCw0LDcuNCwxMS4zcy0yLjksMTEuMy03LjQsMTEuMwoJCWMtNC42LDAtNy40LTMuOS03LjQtMTEuM0MzNjIuNSw5MywzNjUuMyw4OSwzNjkuOSw4OSBNMzY5LjksODMuOWMtOC44LDAtMTQuOCw2LjQtMTQuOCwxNi40czYsMTYuNCwxNC44LDE2LjRzMTQuOS02LjQsMTQuOS0xNi40CgkJUzM3OC43LDgzLjksMzY5LjksODMuOSBNMzUzLjgsNzMuN2MtMS45LTAuNC0zLjktMC41LTYtMC41Yy02LjgsMC0xMCwzLjUtMTAsMTF2MC42aC01LjF2NC44aDUuMXYyNi4zaDYuOFY4OS42aDcuNHYtNC44aC03LjYKCQl2LTAuOWMwLTMuOCwxLjUtNS41LDUuMS01LjVjMSwwLDIuNCwwLjEsNC4xLDAuNHYtNS4xSDM1My44eiIvPgoJPHBhdGggZD0iTTU5NSwyNy43djMxLjFoNi44VjQxYzAtNS40LDMuMi04LjgsNy4yLTguOGMzLjQsMCw1LjMsMi4zLDUuMyw2Ljh2MTkuOGg2LjhWMzguOWMwLTgtMy4zLTEyLTEwLjEtMTIKCQljLTQuMiwwLTcuNCwyLjEtOS42LDYuMnYtNS4zTDU5NSwyNy43TDU5NSwyNy43eiBNNTczLjcsMzJjNC41LDAsNy40LDQsNy40LDExLjNzLTIuOSwxMS4zLTcuNCwxMS4zYy00LjYsMC03LjQtMy45LTcuNC0xMS4zCgkJQzU2Ni4zLDM2LDU2OS4xLDMyLDU3My43LDMyIE01NzMuNywyNi45Yy04LjgsMC0xNC44LDYuNC0xNC44LDE2LjRzNiwxNi40LDE0LjgsMTYuNHMxNC45LTYuNCwxNC45LTE2LjQKCQlDNTg4LjYsMzMuMyw1ODIuNSwyNi45LDU3My43LDI2LjkgTTU0NS41LDU4LjhoNy4xVjI3LjdoLTcuMVY1OC44eiBNNTQ1LjUsMjIuNmg3LjF2LTUuOGgtNy4xVjIyLjZ6IE01MzAuMywxOS4xbC02LjUsMC41bC0wLjIsOAoJCWgtNS40djQuOGg1LjJWNDhjMCw4LjEsMi40LDExLjYsOS44LDExLjZjMS42LDAsMy4zLTAuMiw1LTAuNnYtNS40Yy0xLjIsMC4zLTIuNCwwLjQtMy41LDAuNGMtMy43LDAtNC40LTItNC40LTYuNVYzMi40aDd2LTQuOGgtNwoJCVYxOS4xeiBNNTA2LjIsNDMuM3YyLjJjMCw1LjEtMy42LDktOC4yLDljLTMuNSwwLTUuNi0xLjktNS42LTQuN2MwLTQuNCw0LjEtNi42LDEyLjItNi42aDEuNlY0My4zeiBNNDg1LjksMzUuOGw2LjUsMC44CgkJYzAuNy0zLjIsMy4xLTQuOCw3LjMtNC44YzQuNCwwLDYuNSwxLjksNi41LDUuOHYxLjZoLTAuN2MtMTMuNywwLTIwLjUsMy42LTIwLjUsMTEuMWMwLDUuNCw0LjIsOS4zLDEwLjcsOS4zCgkJYzQuNywwLDguNC0yLjIsMTAuNS02LjJjMC4xLDIsMC4yLDMuOCwwLjcsNS40aDdjLTAuNy0xLjYtMC45LTMuNy0wLjktNi4yVjM5YzAtOC41LTMuNi0xMi4yLTEyLjYtMTIuMgoJCUM0OTIuMiwyNi45LDQ4Ny4zLDI5LjksNDg1LjksMzUuOCBNNDY0LjIsNTguOGg2LjRsMTEtMzEuMWgtNS43bC03LjcsMjMuN2wtNy43LTIzLjdoLTcuMUw0NjQuMiw1OC44eiBNNDM1LjQsMzIKCQljNC41LDAsNy40LDQsNy40LDExLjNzLTIuOSwxMS4zLTcuNCwxMS4zYy00LjYsMC03LjQtMy45LTcuNC0xMS4zQzQyOCwzNiw0MzAuOCwzMiw0MzUuNCwzMiBNNDM1LjQsMjYuOQoJCWMtOC44LDAtMTQuOCw2LjQtMTQuOCwxNi40czYsMTYuNCwxNC44LDE2LjRzMTQuOS02LjQsMTQuOS0xNi40QzQ1MC4zLDMzLjMsNDQ0LjIsMjYuOSw0MzUuNCwyNi45IE0zODguMSwyNy43djMxLjFoNi44VjQxCgkJYzAtNS40LDMuMi04LjgsNy4yLTguOGMzLjQsMCw1LjMsMi4zLDUuMyw2Ljh2MTkuOGg2LjhWMzguOWMwLTgtMy4zLTEyLTEwLjEtMTJjLTQuMiwwLTcuNCwyLjEtOS42LDYuMnYtNS4zTDM4OC4xLDI3LjcKCQlMMzg4LjEsMjcuN3ogTTM1My43LDI3Ljd2MzEuMWg2LjhWNDFjMC01LjQsMy4yLTguOCw3LjItOC44YzMuNCwwLDUuMywyLjMsNS4zLDYuOHYxOS44aDYuOFYzOC45YzAtOC0zLjMtMTItMTAuMS0xMgoJCWMtNC4yLDAtNy40LDIuMS05LjYsNi4ydi01LjNMMzUzLjcsMjcuN0wzNTMuNywyNy43eiBNMzM1LjYsNTguOGg3LjFWMjcuN2gtNy4xVjU4Ljh6IE0zMzUuNiwyMi42aDcuMXYtNS44aC03LjFWMjIuNnoiLz4KPC9nPgo8L3N2Zz4K",
    "bayer.svg": "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjxzdmcKICAgeG1sbnM6ZGM9Imh0dHA6Ly9wdXJsLm9yZy9kYy9lbGVtZW50cy8xLjEvIgogICB4bWxuczpjYz0iaHR0cDovL2NyZWF0aXZlY29tbW9ucy5vcmcvbnMjIgogICB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiCiAgIHhtbG5zOnN2Zz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciCiAgIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIKICAgeG1sbnM6c29kaXBvZGk9Imh0dHA6Ly9zb2RpcG9kaS5zb3VyY2Vmb3JnZS5uZXQvRFREL3NvZGlwb2RpLTAuZHRkIgogICB4bWxuczppbmtzY2FwZT0iaHR0cDovL3d3dy5pbmtzY2FwZS5vcmcvbmFtZXNwYWNlcy9pbmtzY2FwZSIKICAgd2lkdGg9IjEwMDAiCiAgIGhlaWdodD0iMTAwMCIKICAgdmlld0JveD0iMCAwIDYzMy4zMzMzMyA2MzMuMzMzMzMiCiAgIHZlcnNpb249IjEuMSIKICAgaWQ9InN2ZzExIgogICBzb2RpcG9kaTpkb2NuYW1lPSJMb2dvX0JheWVyLnN2ZyIKICAgaW5rc2NhcGU6dmVyc2lvbj0iMC45Mi4zICgyNDA1NTQ2LCAyMDE4LTAzLTExKSI+CiAgPG1ldGFkYXRhCiAgICAgaWQ9Im1ldGFkYXRhMTciPgogICAgPHJkZjpSREY+CiAgICAgIDxjYzpXb3JrCiAgICAgICAgIHJkZjphYm91dD0iIj4KICAgICAgICA8ZGM6Zm9ybWF0PmltYWdlL3N2Zyt4bWw8L2RjOmZvcm1hdD4KICAgICAgICA8ZGM6dHlwZQogICAgICAgICAgIHJkZjpyZXNvdXJjZT0iaHR0cDovL3B1cmwub3JnL2RjL2RjbWl0eXBlL1N0aWxsSW1hZ2UiIC8+CiAgICAgIDwvY2M6V29yaz4KICAgIDwvcmRmOlJERj4KICA8L21ldGFkYXRhPgogIDxkZWZzCiAgICAgaWQ9ImRlZnMxNSIgLz4KICA8c29kaXBvZGk6bmFtZWR2aWV3CiAgICAgcGFnZWNvbG9yPSIjZmZmZmZmIgogICAgIGJvcmRlcmNvbG9yPSIjNjY2NjY2IgogICAgIGJvcmRlcm9wYWNpdHk9IjEiCiAgICAgb2JqZWN0dG9sZXJhbmNlPSIxMCIKICAgICBncmlkdG9sZXJhbmNlPSIxMCIKICAgICBndWlkZXRvbGVyYW5jZT0iMTAiCiAgICAgaW5rc2NhcGU6cGFnZW9wYWNpdHk9IjAiCiAgICAgaW5rc2NhcGU6cGFnZXNoYWRvdz0iMiIKICAgICBpbmtzY2FwZTp3aW5kb3ctd2lkdGg9IjEzNjYiCiAgICAgaW5rc2NhcGU6d2luZG93LWhlaWdodD0iNzA1IgogICAgIGlkPSJuYW1lZHZpZXcxMyIKICAgICBzaG93Z3JpZD0iZmFsc2UiCiAgICAgaW5rc2NhcGU6em9vbT0iMC4zNTM1NTMzOSIKICAgICBpbmtzY2FwZTpjeD0iNjQzLjA4OTY4IgogICAgIGlua3NjYXBlOmN5PSI0NTcuODEyOTciCiAgICAgaW5rc2NhcGU6d2luZG93LXg9Ii04IgogICAgIGlua3NjYXBlOndpbmRvdy15PSItOCIKICAgICBpbmtzY2FwZTp3aW5kb3ctbWF4aW1pemVkPSIxIgogICAgIGlua3NjYXBlOmN1cnJlbnQtbGF5ZXI9InN2ZzExIgogICAgIGlua3NjYXBlOm1lYXN1cmUtc3RhcnQ9IjAsMCIKICAgICBpbmtzY2FwZTptZWFzdXJlLWVuZD0iMCwwIiAvPgogIDxzdHlsZQogICAgIHR5cGU9InRleHQvY3NzIgogICAgIGlkPSJzdHlsZTIiPgoJLnN0MHtmaWxsOiMxMDM4NEY7fQoJLnN0MXtmaWxsOiM4OUQzMjk7fQoJLnN0MntmaWxsOiMwMEJDRkY7fQo8L3N0eWxlPgogIDxnCiAgICAgaWQ9Imc0MyI+CiAgICA8ZwogICAgICAgaWQ9Imc5NzUiPgogICAgICA8cGF0aAogICAgICAgICBzdHlsZT0iZmlsbDojODlkMzI5O3N0cm9rZS13aWR0aDo4LjMzMzMzMzAyIgogICAgICAgICBpbmtzY2FwZTpjb25uZWN0b3ItY3VydmF0dXJlPSIwIgogICAgICAgICBpZD0icGF0aDYiCiAgICAgICAgIGQ9Ik0gNjMyLjUsMjk2LjY2NjY3IEMgNjIyLjUsMTMxLjY2NjY3IDQ4NSwwIDMxNi42NjY2NywwIDE0OC4zMzMzMywwIDEwLjgzMzMzMywxMzEuNjY2NjcgMC44MzMzMzMyOSwyOTYuNjY2NjcgYyAwLDYuNjY2NjYgMC44MzMzMzMzMSwxMy4zMzMzMyAxLjY2NjY2NjcxLDIwIEMgOS4xNjY2NjY2LDM3MS42NjY2NyAzMCw0MjIuNSA2MS42NjY2NjYsNDY1IDExOS4xNjY2Nyw1NDMuMzMzMzMgMjExLjY2NjY3LDU5NC4xNjY2NiAzMTYuNjY2NjcsNTk0LjE2NjY2IDE3MCw1OTQuMTY2NjYgNTAsNDgwIDQwLDMzNi42NjY2NyBjIC0wLjgzMzMzNCwtNi42NjY2NyAtMC44MzMzMzQsLTEzLjMzMzM0IC0wLjgzMzMzNCwtMjAgMCwtNi42NjY2NyAwLC0xMy4zMzMzNCAwLjgzMzMzNCwtMjAgQyA1MCwxNTMuMzMzMzMgMTcwLDM5LjE2NjY2NyAzMTYuNjY2NjcsMzkuMTY2NjY3IGMgMTA0Ljk5OTk5LDAgMTk3LjQ5OTk5LDUwLjgzMzMzMyAyNTQuOTk5OTksMTI5LjE2NjY2MyAzMS42NjY2Nyw0Mi41IDUyLjUsOTMuMzMzMzQgNTkuMTY2NjcsMTQ4LjMzMzM0IDAuODMzMzMsNi42NjY2NiAxLjY2NjY3LDEzLjMzMzMzIDEuNjY2NjcsMTkuMTY2NjYgMCwtNi42NjY2NiAwLjgzMzMzLC0xMy4zMzMzMyAwLjgzMzMzLC0yMCAwLC01LjgzMzMzIDAsLTEyLjUgLTAuODMzMzMsLTE5LjE2NjY2IgogICAgICAgICBjbGFzcz0ic3QxIiAvPgogICAgICA8cGF0aAogICAgICAgICBzdHlsZT0iZmlsbDojMDBiY2ZmO3N0cm9rZS13aWR0aDo4LjMzMzMzMzAyIgogICAgICAgICBpbmtzY2FwZTpjb25uZWN0b3ItY3VydmF0dXJlPSIwIgogICAgICAgICBpZD0icGF0aDgiCiAgICAgICAgIGQ9Ik0gMC44MzMzMzMyOSwzMzYuNjY2NjcgQyAxMC44MzMzMzMsNTAxLjY2NjY2IDE0OC4zMzMzMyw2MzMuMzMzMzMgMzE2LjY2NjY3LDYzMy4zMzMzMyA0ODUsNjMzLjMzMzMzIDYyMi41LDUwMS42NjY2NiA2MzIuNSwzMzYuNjY2NjcgYyAwLC02LjY2NjY3IC0wLjgzMzM0LC0xMy4zMzMzNCAtMS42NjY2NywtMjAgLTYuNjY2NjcsLTU1IC0yNy41LC0xMDUuODMzMzQgLTU5LjE2NjY3LC0xNDguMzMzMzQgLTU3LjUsLTc4LjMzMzMzIC0xNTAsLTEyOS4xNjY2NjMgLTI1NC45OTk5OSwtMTI5LjE2NjY2MyAxNDYuNjY2NjYsMCAyNjYuNjY2NjYsMTE0LjE2NjY2MyAyNzYuNjY2NjYsMjU3LjUwMDAwMyAwLjgzMzMzLDYuNjY2NjYgMC44MzMzMywxMy4zMzMzMyAwLjgzMzMzLDIwIDAsNi42NjY2NiAwLDEzLjMzMzMzIC0wLjgzMzMzLDIwIC0xMCwxNDQuMTY2NjYgLTEzMCwyNTcuNDk5OTkgLTI3Ni42NjY2NiwyNTcuNDk5OTkgLTEwNSwwIC0xOTcuNSwtNTAuODMzMzMgLTI1NS4wMDAwMDQsLTEyOS4xNjY2NiBDIDMwLDQyMi41IDkuMTY2NjY2NiwzNzEuNjY2NjcgMi41LDMxNi42NjY2NyAxLjY2NjY2NjYsMzEwIDAuODMzMzMzMjksMzAzLjMzMzMzIDAuODMzMzMzMjksMjk3LjUgYyAwLDYuNjY2NjcgLTAuODMzMzMzMzMsMTMuMzMzMzMgLTAuODMzMzMzMzMsMjAgMCw1LjgzMzMzIDAsMTIuNSAwLjgzMzMzMzMzLDE5LjE2NjY3IgogICAgICAgICBjbGFzcz0ic3QyIiAvPgogICAgPC9nPgogICAgPGcKICAgICAgIGlkPSJnMjgiPgogICAgICA8cGF0aAogICAgICAgICBpbmtzY2FwZTpjb25uZWN0b3ItY3VydmF0dXJlPSIwIgogICAgICAgICBzdHlsZT0iZmlsbDojMTAzODRmO3N0cm9rZS13aWR0aDoxMy4xNTc4OTQxMyIKICAgICAgICAgZD0iTSA0MzguMTU4Miw5Ni4wNTI3MzQgViAyMzQuMjEwOTQgaCA5Ni4wNTI3NCBjIDIzLjY4NDIxLDAgNDIuMTA1NDcsLTE4LjQyMTI2IDQyLjEwNTQ3LC00Mi4xMDU0NyAwLC0xMS44NDIxMSAtNS4yNjM0NywtMjIuMzY4OTQgLTEzLjE1ODIxLC0zMC4yNjM2NyA1LjI2MzE2LC02LjU3ODk1IDkuMjA5NjEsLTE1Ljc4OTQ4IDEwLjUyNTM5LC0yNSAwLC0yMi4zNjg0MiAtMTguNDIwNjMsLTQwLjc4OTA2NiAtNDAuNzg5MDYsLTQwLjc4OTA2NiB6IE0gNDY5LjczNjMzLDEyNSBoIDU3Ljg5NDUzIGMgNi41Nzg5NCwwIDExLjg0Mzc1LDUuMjYyODUgMTEuODQzNzUsMTEuODQxOCAwLDYuNTc4OTQgLTUuMjY0ODEsMTEuODQxNzkgLTExLjg0Mzc1LDExLjg0MTc5IGggLTU3Ljg5NDUzIHogbSAwLDUyLjYzMDg2IGggNTkuMjEwOTQgYyA3Ljg5NDczLDAgMTMuMTU4Miw1LjI2MzQ3IDEzLjE1ODIsMTMuMTU4MiAwLDcuODk0NzQgLTUuMjYzNDcsMTMuMTU4MjEgLTEzLjE1ODIsMTMuMTU4MjEgaCAtNTkuMjEwOTQgeiIKICAgICAgICAgdHJhbnNmb3JtPSJzY2FsZSgwLjYzMzMzMzMzKSIKICAgICAgICAgaWQ9InBhdGg4NTgiIC8+CiAgICAgIDxwYXRoCiAgICAgICAgIGlua3NjYXBlOmNvbm5lY3Rvci1jdXJ2YXR1cmU9IjAiCiAgICAgICAgIHN0eWxlPSJmaWxsOiMxMDM4NGY7c3Ryb2tlLXdpZHRoOjEzLjE1Nzg5NDEzIgogICAgICAgICBkPSJtIDQ4NC4yMTA5NCwyNjAuNTI1MzkgLTY4LjQyMTg4LDEzOC4xNTgyIGggMzUuNTI3MzUgTCA0NjEuODQxOCwzNzUgaCA3Ny42MzI4MSBMIDU1MCwzOTguNjgzNTkgaCAzNS41MjUzOSBMIDUxNS43ODkwNiwyNjAuNTI1MzkgWiBNIDUwMCwyOTYuMDUyNzMgbCAyMy42ODM1OSw1MCBoIC00Ny4zNjcxOCB6IgogICAgICAgICB0cmFuc2Zvcm09InNjYWxlKDAuNjMzMzMzMzMpIgogICAgICAgICBpZD0icGF0aDg1MiIgLz4KICAgICAgPHBhdGgKICAgICAgICAgaW5rc2NhcGU6Y29ubmVjdG9yLWN1cnZhdHVyZT0iMCIKICAgICAgICAgc3R5bGU9ImZpbGw6IzEwMzg0ZjtzdHJva2Utd2lkdGg6OC4zMzMzMzMwMiIKICAgICAgICAgZD0ibSAzNDYuNjY2NjcsMjcxLjY2NjY3IGggMjUgTCAzMjcuNSwzMjguMzMzMzMgdiAzMC44MzMzNCBIIDMwNi42NjY2NyBWIDMyOC4zMzMzMyBMIDI2Mi41LDI3MS42NjY2NyBoIDI1IGwgMzAsNDAgeiIKICAgICAgICAgaWQ9InBhdGg4NDgiIC8+CiAgICAgIDxwYXRoCiAgICAgICAgIGlua3NjYXBlOmNvbm5lY3Rvci1jdXJ2YXR1cmU9IjAiCiAgICAgICAgIHN0eWxlPSJmaWxsOiMxMDM4NGY7ZmlsbC1vcGFjaXR5OjE7c3Ryb2tlLXdpZHRoOjEzLjE1Nzg5NDEzIgogICAgICAgICBkPSJtIDc3My42ODM1OSw0MjguOTQ3MjcgdiAxMzguMTU4MiBoIDMyLjg5NDUzIHYgLTUyLjYzMDg2IGggMjUgbCAzOS40NzQ2MSw1Mi42MzA4NiBoIDM5LjQ3MjY2IEwgODY5LjczNjMzLDUxMy4xNTgyIEMgODg2Ljg0MTU5LDUwNy44OTUwNSA5MDAsNDkyLjEwNTk4IDkwMCw0NzIuMzY5MTQgYyAwLC0yMy42ODQyMSAtMTguNDIxMjYsLTQzLjQyMTg3IC00Mi4xMDU0NywtNDMuNDIxODcgeiBtIDM0LjIxMDk0LDI4Ljk0NzI2IGggNDcuMzY5MTQgYyA2LjU3ODk1LDAgMTMuMTU4MjEsNi41NzkyNyAxMy4xNTgyMSwxMy4xNTgyIDAsNi41Nzg5NiAtNS4yNjM0NywxMy4xNTgyMSAtMTMuMTU4MjEsMTMuMTU4MjEgaCAtNDcuMzY5MTQgeiIKICAgICAgICAgaWQ9InBhdGg4NDQiCiAgICAgICAgIHRyYW5zZm9ybT0ic2NhbGUoMC42MzMzMzMzMykiIC8+CiAgICAgIDxwYXRoCiAgICAgICAgIGlua3NjYXBlOmNvbm5lY3Rvci1jdXJ2YXR1cmU9IjAiCiAgICAgICAgIHN0eWxlPSJmaWxsOiMxMDM4NGY7c3Ryb2tlLXdpZHRoOjguMzMzMzMzMDIiCiAgICAgICAgIGQ9Im0gNjQuMTY2NjY2LDI3MS42NjY0NyB2IDg3LjUwMDIgaCA2MC44MzM0MDQgYyAxNSwwIDI2LjY2NjgsLTExLjY2NjggMjYuNjY2OCwtMjYuNjY2OCAwLC03LjUwMDAxIC0zLjMzMzUzLC0xNC4xNjcgLTguMzMzNTQsLTE5LjE2NyAzLjMzMzM0LC00LjE2NjY2IDUuODMyNzYsLTEwIDYuNjY2MDksLTE1LjgzMzMzIDAsLTE0LjE2NjY2IC0xMS42NjY0LC0yNS44MzMwNyAtMjUuODMzMDgsLTI1LjgzMzA3IHogbSAxOS45OTk0ODIsMTguMzMzMjYgaCAzNi42NjY1NDIgYyA0LjE2NjY2LDAgNy41MDEwNCwzLjMzMzE0IDcuNTAxMDQsNy40OTk4MSAwLDQuMTY2NjYgLTMuMzM0MzgsNy40OTk4IC03LjUwMTA0LDcuNDk5OCBIIDg0LjE2NjE0OCBaIG0gMCwzMy4zMzI4OCBoIDM3LjUwMDI2MiBjIDUsMCA4LjMzMzUzLDMuMzMzNTMgOC4zMzM1Myw4LjMzMzUzIDAsNSAtMy4zMzM1Myw4LjMzMzUzIC04LjMzMzUzLDguMzMzNTMgSCA4NC4xNjYxNDggWiIKICAgICAgICAgaWQ9InBhdGg4NTgtMCIgLz4KICAgICAgPHBhdGgKICAgICAgICAgaW5rc2NhcGU6Y29ubmVjdG9yLWN1cnZhdHVyZT0iMCIKICAgICAgICAgc3R5bGU9ImZpbGw6IzEwMzg0ZjtzdHJva2Utd2lkdGg6OC4zMzMzMzMwMiIKICAgICAgICAgZD0ibSAyMDcuNTAwNzksMjcxLjY2NjYxIC00My4zMzM4Niw4Ny41MDAxOSBoIDIyLjUwMDY1IGwgNi42NjYwOCwtMTQuOTk5NiBoIDQ5LjE2NzQ1IGwgNi42NjYwOCwxNC45OTk2IGggMjIuNDk5NDIgbCAtNDQuMTY2MzUsLTg3LjUwMDE5IHogbSA5Ljk5OTczLDIyLjUwMDY1IDE0Ljk5OTYxLDMxLjY2NjY2IGggLTI5Ljk5OTIxIHoiCiAgICAgICAgIGlkPSJwYXRoODUyLTgiIC8+CiAgICAgIDxwYXRoCiAgICAgICAgIGlua3NjYXBlOmNvbm5lY3Rvci1jdXJ2YXR1cmU9IjAiCiAgICAgICAgIHN0eWxlPSJmaWxsOiMxMDM4NGY7ZmlsbC1vcGFjaXR5OjE7c3Ryb2tlLXdpZHRoOjguMjU1MDkyNjIiCiAgICAgICAgIGQ9Im0gNDYyLjUwMDAxLDI3MS42NjY2NyB2IDE4LjgwODQ2IGggLTU4LjMzMzM1IHYgMTQuNzE5NjYgaCA1Ni42NjY2NyB2IDE4LjgwODQ1IGggLTU2LjY2NjY3IHYgMTYuMzU1MTcgaCA1OC4zMzMzNSB2IDE4LjgwODQ2IGggLTc5LjE2NjY4IHYgLTg3LjUwMDIgeiIKICAgICAgICAgaWQ9InBhdGg4MzAtNyIgLz4KICAgICAgPHBhdGgKICAgICAgICAgaW5rc2NhcGU6Y29ubmVjdG9yLWN1cnZhdHVyZT0iMCIKICAgICAgICAgc3R5bGU9ImZpbGw6IzEwMzg0ZjtmaWxsLW9wYWNpdHk6MTtzdHJva2Utd2lkdGg6OC4zMzMzMzMwMiIKICAgICAgICAgZD0ibSAyNzYuNjY2NDcsNDg2LjY2NzE5IHYgODcuNTAwMTkgaCAyMC44MzMyIFYgNTQwLjgzNDUgaCAxNS44MzMzNCBsIDI1LjAwMDU4LDMzLjMzMjg4IGggMjQuOTk5MzYgbCAtMjUuODMzMDgsLTM0LjE2NjYgYyAxMC44MzMzNCwtMy4zMzMzMyAxOS4xNjcsLTEzLjMzMzA4IDE5LjE2NywtMjUuODMzMDcgMCwtMTUgLTExLjY2NjgsLTI3LjUwMDUyIC0yNi42NjY4LC0yNy41MDA1MiB6IG0gMjEuNjY2OTMsMTguMzMzMjYgaCAzMC4wMDA0NiBjIDQuMTY2NjYsMCA4LjMzMzUzLDQuMTY2ODcgOC4zMzM1Myw4LjMzMzUzIDAsNC4xNjY2NyAtMy4zMzM1Myw4LjMzMzUzIC04LjMzMzUzLDguMzMzNTMgSCAyOTguMzMzNCBaIgogICAgICAgICBpZD0icGF0aDg0NC03IiAvPgogICAgICA8cGF0aAogICAgICAgICBpbmtzY2FwZTpjb25uZWN0b3ItY3VydmF0dXJlPSIwIgogICAgICAgICBzdHlsZT0iZmlsbDojMTAzODRmO2ZpbGwtb3BhY2l0eToxO3N0cm9rZS13aWR0aDo4LjI1NTA5MjYyIgogICAgICAgICBkPSJtIDM1Ni42NjY2OCwzNzguMTM4NTUgdiAxOC44MDg0NiBoIC01OC4zMzMzNSB2IDE0LjcxOTY2IEggMzU1IHYgMTguODA4NDUgaCAtNTYuNjY2NjcgdiAxNi4zNTUxNyBoIDU4LjMzMzM1IHYgMTguODA4NDYgSCAyNzcuNSB2IC04Ny41MDAyIHoiCiAgICAgICAgIGlkPSJwYXRoODMwLTctNiIgLz4KICAgIDwvZz4KICA8L2c+Cjwvc3ZnPgo=",
    "roche.svg": "PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxMTY1Ljg5MSIgaGVpZ2h0PSI2MTAiIHZpZXdCb3g9IjAgMCAxMTY1Ljg5MSA2MTAiPjxnIGZpbGw9IiMwMDdhYzIiIHRyYW5zZm9ybT0ibWF0cml4KDAuNDYyMzU2NDgsMCwwLDAuNDYyMzU2NDgsNSw0Ljk5OTk5NTkpIj48cGF0aCBkPSJtIDE2OTEuMSw0OTguMSBjIC0xNS43LC0xMS43IC00MC4zLC0xOC44IC02NC4yLC0xOC40IC0yNiwwLjQgLTUwLjgsOC43IC02OCwyMi41IFYgMzM4LjMgaCAtODEuMSB2IDUzNC41IGggODEuMSB2IC0yNzkgYyAwLC0xOS41IDE2LjMsLTQwLjkgNDYuNSwtNDIuMiAxMy41LC0wLjYgMzIuMSw1LjMgNDEuNiwxOS40IDEwLjEsMTUgOS41LDM0LjkgOS41LDU2LjYgbCAtMC4xLDI0NS4xIGggODEuMSBWIDYyNC42IGMgLTAuMSwtNzMuMiAtOS42LC05OS4zIC00Ni40LC0xMjYuNSBtIC02NTkuNCwxODMuNSBjIDAsNTIuMyAtMS43LDY3IC0yLjEsNzEuNiAtMi44LDI5IC0xNS4yLDU5LjcgLTQ5LDU5LjcgLTMzLjcsMCAtNDcuNCwtMzIuOCAtNDguOSwtNjEuMSAtMC4xLC0wLjIgLTIuMSwtMTcuOSAtMi4xLC03MC4yIDAsLTUyLjQgMi4xLC03NC4yIDIuMSwtNzQuNCAwLjQsLTI5LjUgMTUuNywtNTkuMSA0OC45LC01OS4xIDMzLjIsMCA0OC41LDI5LjUgNDksNTguNyAwLjEsMC42IDIuMSwyMi40IDIuMSw3NC44IG0gNzguNSwtNjMuMSBjIC0xMS41LC0xMTQuMyAtNzYuNCwtMTM4LjggLTEyOS42LC0xMzguOCAtNzUuNSwwIC0xMjEuNCw0OCAtMTI5LjcsMTM4LjYgLTAuNyw3LjIgLTEuOCwyMC41IC0yLjIsNjMuMiAtMC4zLDMxLjEgMS43LDU2LjUgMi4xLDYzIDUuMSw4NC42IDUzLjgsMTM2LjggMTI5LjgsMTM2LjggNzYuMSwwIDEyNC41LC01MyAxMjkuOCwtMTM2LjggMC40LC02IDIuMSwtMzEuOSAyLjEsLTYzIDAsLTE0IC0xLjMsLTUyLjMgLTIuMywtNjMgeiBtIDc2Mi41LDE1IGMgMC42LC0xNy43IDAuNiwtMjEuNCAxLC0yNi41IDIuMywtMzIgMTYuNiwtNTguNSA0OS40LC01OC44IDM4LjksLTAuMyA0OCwzNy44IDQ5LjQsNTguOSAwLjcsMTEuMSAxLjUsMTguNSAxLjQsMjYuNCB6IG0gMTAwLjIsMTA3LjEgYyAwLDAgMC4xLDYgLTAuOCwxMy4yIC0yLjMsMTguOSAtOS43LDU5LjIgLTQ5LjIsNTkuMiAtMzMuNiwwIC00Ni42LC0zMC41IC00OC44LC02MSAtMC40LC04LjYgLTIsLTE4LjMgLTEuOSwtNTEuMSBIIDIwNTMgYyAwLDAgMC4zLC0yNi45IC0wLjIsLTQzLjEgLTAuMywtNi40IC0wLjYsLTE2LjkgLTIuMSwtMzkuMiAtMi41LC0zNC4zIC0xNS4zLC03MS43IC0zNC45LC05NiAtMjIuNywtMjggLTU0LjgsLTQyLjggLTkyLjgsLTQyLjggLTczLDAgLTExOC43LDQ3LjYgLTEyNy42LDEzOC43IC0wLjgsOC4yIC0yLjEsMTkuNSAtMi4xLDYzLjIgMCwzMS4xIDEuOCw1Ny4xIDIuMSw2MyA0LjksODMuMiA1NC4xLDEzNi44IDEyNy43LDEzNi44IDczLjQsMCAxMjIuNiwtNTIuMSAxMjcuOCwtMTQwLjggeiIvPjxwYXRoIGQ9Ik0gNTkyLjIsNjUuNSBIIDE5MDkuNyBMIDI0MTMuNiw2NTUgMTkwOS45LDEyMzYuNCBIIDU5Mi4yIEwgODYuNSw2NTMgWiBNIDE5NDEuNiwwIEggNTYwLjQgTCAwLDY1MC45IDU2MC41LDEyOTcuNyBIIDE5NDEuNiBMIDI1MDAsNjUzIFoiLz48cGF0aCBkPSJtIDYwOC41LDQxMC44IGggMzguNCBjIDQxLjcsMCA2NC4zLDIyLjEgNjUuMyw2MS42IDAuMSwyLjkgMC40LDYuMiAwLjQsMTIuMyAwLDcuMiAtMC4xLDkuOCAtMC40LDEyLjUgLTIuMywyMy41IC0xMi42LDY0LjQgLTYxLjUsNjQuNCBoIC00Mi4zIHogbSAxOTIsNDI4LjggLTguMywtMTMxLjIgYyAtMy42LC01OC43IC0xOC45LC05My4zIC00OS4zLC0xMTEgMjEuOSwtMTMuMiA1MC4zLC00NS44IDUwLC0xMTMuOSAtMC40LC0xMDMuOCAtNjQuOCwtMTQwLjIgLTE0MC42LC0xNDEgSCA1MjguNSB2IDUzMC4yIGggODAgViA2MzAuMSBIIDY1MyBjIDI1LjgsMCA1NC44LDIyLjUgNTkuMiw4NS44IGwgOC4zLDEyNC4yIGMgMC43LDE3LjYgNCwzMi42IDQsMzIuNiBoIDgwLjEgYyAwLjEsMC4xIC0zLjQsLTE0LjYgLTQuMSwtMzMuMSB6IE0gMTM0Nyw3MzYuOSBjIC0wLjMsNS44IC0wLjcsMTEuMSAtMSwxNC45IC0yLjMsMjkuNiAtMTIuNyw2MS4xIC00OC45LDYxLjEgLTMzLjgsMCAtNDcuMSwtMzQuMSAtNDkuNiwtNTkuMyAtMS41LC0xNS4zIC0xLjEsLTI3LjEgLTEuNCwtNzIgLTAuNCwtNTIuNCAxLjMsLTY1LjkgMi4xLC03NC40IDIuOSwtMzMuMSAxNS43LC01OC44IDQ4LjksLTU5IDM0LjIsLTAuMiA0OC41LDI5LjUgNDguOSw1OC43IDAsMC4zIDAuNyw3LjQgMS4yLDIyLjkgaCA4MC4yIGMgLTAuMywtNS40IC0wLjUsLTkuOCAtMC43LC0xMi40IC05LjEsLTExMC44IC03Ni42LC0xMzcuNiAtMTI5LjgsLTEzNy42IC03NS40LDAgLTEyMS40LDQ4IC0xMjkuNywxMzguNiAtMC43LDcuMiAtMS44LDIwLjUgLTIuMiw2My4yIC0wLjQsMzEuMSAxLjYsNTYuNSAyLjEsNjMgNS4yLDg0LjYgNTMuOCwxMzYuNiAxMjkuOCwxMzYuOCA3OC44LDAuMyAxMjIuMywtNDcuOCAxMjkuOCwtMTM2LjggMC4yLC0zLjIgMC43LC01LjUgMC41LC03LjcgeiIvPjwvZz48L3N2Zz4=",
    "astrazeneca.svg": "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhLS0gR2VuZXJhdG9yOiBBZG9iZSBJbGx1c3RyYXRvciAxMy4wLjEsIFNWRyBFeHBvcnQgUGx1Zy1JbiAgLS0+Cgo8c3ZnCiAgIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIKICAgeG1sbnM6Y2M9Imh0dHA6Ly9jcmVhdGl2ZWNvbW1vbnMub3JnL25zIyIKICAgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIgogICB4bWxuczpzdmc9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogICB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciCiAgIHhtbG5zOnNvZGlwb2RpPSJodHRwOi8vc29kaXBvZGkuc291cmNlZm9yZ2UubmV0L0RURC9zb2RpcG9kaS0wLmR0ZCIKICAgeG1sbnM6aW5rc2NhcGU9Imh0dHA6Ly93d3cuaW5rc2NhcGUub3JnL25hbWVzcGFjZXMvaW5rc2NhcGUiCiAgIHZlcnNpb249IjEuMSIKICAgeD0iMHB4IgogICB5PSIwcHgiCiAgIHdpZHRoPSIzMDAiCiAgIGhlaWdodD0iNDMiCiAgIHZpZXdCb3g9Ii0wLjgzNSAtMC41MDkgMzAwIDQzIgogICBlbmFibGUtYmFja2dyb3VuZD0ibmV3IC0wLjgzNSAtMC41MDkgMTg4IDQ4IgogICB4bWw6c3BhY2U9InByZXNlcnZlIgogICBpZD0ic3ZnMzA2MCIKICAgaW5rc2NhcGU6dmVyc2lvbj0iMC40OC4xICIKICAgc29kaXBvZGk6ZG9jbmFtZT0iYXN0cmF6ZW5lY2Fsb2dvdGV4dC5zdmciPjxtZXRhZGF0YQogICBpZD0ibWV0YWRhdGEzMDkwIj48cmRmOlJERj48Y2M6V29yawogICAgICAgcmRmOmFib3V0PSIiPjxkYzpmb3JtYXQ+aW1hZ2Uvc3ZnK3htbDwvZGM6Zm9ybWF0PjxkYzp0eXBlCiAgICAgICAgIHJkZjpyZXNvdXJjZT0iaHR0cDovL3B1cmwub3JnL2RjL2RjbWl0eXBlL1N0aWxsSW1hZ2UiIC8+PC9jYzpXb3JrPjwvcmRmOlJERj48L21ldGFkYXRhPjxzb2RpcG9kaTpuYW1lZHZpZXcKICAgcGFnZWNvbG9yPSIjZmZmZmZmIgogICBib3JkZXJjb2xvcj0iIzY2NjY2NiIKICAgYm9yZGVyb3BhY2l0eT0iMSIKICAgb2JqZWN0dG9sZXJhbmNlPSIxMCIKICAgZ3JpZHRvbGVyYW5jZT0iMTAiCiAgIGd1aWRldG9sZXJhbmNlPSIxMCIKICAgaW5rc2NhcGU6cGFnZW9wYWNpdHk9IjAiCiAgIGlua3NjYXBlOnBhZ2VzaGFkb3c9IjIiCiAgIGlua3NjYXBlOndpbmRvdy13aWR0aD0iMTM2NiIKICAgaW5rc2NhcGU6d2luZG93LWhlaWdodD0iNzA2IgogICBpZD0ibmFtZWR2aWV3MzA4OCIKICAgc2hvd2dyaWQ9ImZhbHNlIgogICBpbmtzY2FwZTp6b29tPSIyLjU1MzE5MTUiCiAgIGlua3NjYXBlOmN4PSIxOTUuNDAxOTUiCiAgIGlua3NjYXBlOmN5PSIyNCIKICAgaW5rc2NhcGU6d2luZG93LXg9IjAiCiAgIGlua3NjYXBlOndpbmRvdy15PSIwIgogICBpbmtzY2FwZTp3aW5kb3ctbWF4aW1pemVkPSIxIgogICBpbmtzY2FwZTpjdXJyZW50LWxheWVyPSJzdmczMDYwIiAvPgo8ZGVmcwogICBpZD0iZGVmczMwNjIiPgo8L2RlZnM+CgoKCgoKCgoKCgo8ZwogICBpZD0iZzMwOTIiCiAgIHRyYW5zZm9ybT0ibWF0cml4KDEuOTQ1OTczOSwwLDAsMS45NDU5NzM5LDEuNjUwMDAwMSwtNDguNzM4ODE4KSI+PHBhdGgKICAgICBzdHlsZT0iZmlsbDojOGEwMDUxO2ZpbGwtcnVsZTpldmVub2RkIgogICAgIGlua3NjYXBlOmNvbm5lY3Rvci1jdXJ2YXR1cmU9IjAiCiAgICAgaWQ9InBhdGgzMDY0IgogICAgIGQ9Im0gNS45NiwzNy4xOTkgMy4wODEsLTguMzY2IDIuOTM5LDguMzY2IEggNS45NiBsIDAsMCB6IG0gOS4wMTQsOC40MzEgaCAyLjgyNSBMIDEwLjQ2NywyNS40OTEgSCA3LjY3MyBMIDAsNDUuNjMgaCAyLjg1MiBsIDIuMjUzLC02LjE3MiBoIDcuNjczIGwgMi4xOTYsNi4xNzIgMCwwIHoiCiAgICAgY2xpcC1ydWxlPSJldmVub2RkIiAvPjxwYXRoCiAgICAgc3R5bGU9ImZpbGw6IzhhMDA1MTtmaWxsLXJ1bGU6ZXZlbm9kZCIKICAgICBpbmtzY2FwZTpjb25uZWN0b3ItY3VydmF0dXJlPSIwIgogICAgIGlkPSJwYXRoMzA2NiIKICAgICBkPSJtIDIzLjk0MSwzOC42NzUgYyAtMi42MTgsLTAuNTY2IC01LjMyMiwtMS4xODQgLTUuMzIyLC00LjM0MiAwLC0yLjc3MyAyLjM0NSwtNC41MjEgNS44ODcsLTQuNTIxIDIuMjkxLDAgNC40NzksMC44NTMgNS41NzEsMi45MzggbCAtMi4zODIsMC45OTQgYyAtMC4xOTEsLTAuNTU3IC0xLjQyNCwtMS45NTkgLTMuNDgxLC0xLjk1OSAtMi4wMTYsMCAtMy4wMjUsMS4xOTMgLTMuMDI1LDIuMjI2IDAsMS40NSAxLjkxNywyLjA1NCAzLjU1MiwyLjM4MyAzLjM4NSwwLjY4MSA2LjMyOCwxLjU0NyA2LjMyOCw0LjczOCAwLDIuNDggLTIuMjAzLDQuODEgLTYuNDExLDQuODEgLTMuMDk4LDAgLTUuMjk5LC0xLjAzNiAtNi4zNTgsLTMuMjAxIGwgMi43MTcsLTAuNDc0IGMgMC42ODIsMS4xODYgMS45MTUsMS43IDMuNzUyLDEuNyAyLjI3OCwwIDMuNjEsLTAuODY5IDMuNjEsLTIuNTE0IDEwZS00LC0xLjc0IC0yLjE4NSwtMi4yOTEgLTQuNDM4LC0yLjc3OCBsIDAsMCB6IgogICAgIGNsaXAtcnVsZT0iZXZlbm9kZCIgLz48cGF0aAogICAgIHN0eWxlPSJmaWxsOiM4YTAwNTE7ZmlsbC1ydWxlOmV2ZW5vZGQiCiAgICAgaW5rc2NhcGU6Y29ubmVjdG9yLWN1cnZhdHVyZT0iMCIKICAgICBpZD0icGF0aDMwNjgiCiAgICAgZD0ibSAzNi43MTEsMzAuMjc2IGggMi43ODIgdiAyLjE0MSBoIC0yLjc4MiB2IDguNzEyIGMgMCwxLjgwNyAwLDIuNTgyIDEuMDk5LDIuNTgyIDAuNDg1LDAgMS4xNjYsLTAuMTk1IDEuNjgzLC0wLjM1NSB2IDIuMTIgQyAzOS4wNCw0NS41NCAzNy45NzEsNDUuNzM0IDM3LDQ1LjczNCBjIC0yLjk3NSwwIC0yLjk3NSwtMS40NDYgLTIuOTQzLC0zLjQ0MiBWIDMyLjQxNyBIIDMxLjYzIHYgLTIuMTQxIGggMi40MjcgdiAtMy42NTggbCAyLjY1NCwtMS4xMDQgdiA0Ljc2MiBsIDAsMCB6IgogICAgIGNsaXAtcnVsZT0iZXZlbm9kZCIgLz48cGF0aAogICAgIHN0eWxlPSJmaWxsOiM4YTAwNTE7ZmlsbC1ydWxlOmV2ZW5vZGQiCiAgICAgaW5rc2NhcGU6Y29ubmVjdG9yLWN1cnZhdHVyZT0iMCIKICAgICBpZD0icGF0aDMwNzAiCiAgICAgZD0ibSA0NC4zODEsMzAuMzE1IHYgMi43NDIgYyAxLjQ1NSwtMi44OTMgNC4yMDYsLTIuOTU4IDUuMjQxLC0yLjk5IHYgMi42NTMgYyAtMi41MjMsMC4wMTcgLTMuNzYsMC41MzQgLTQuNTkzLDEuODkxIC0wLjY4NCwxLjEwOCAtMC42NDgsMi42NjUgLTAuNjQ4LDMuOTggViA0NS42MyBIIDQxLjgxMiBWIDMwLjMxNSBoIDIuNTY5IGwgMCwwIHoiCiAgICAgY2xpcC1ydWxlPSJldmVub2RkIiAvPjxwb2x5Z29uCiAgICAgc3R5bGU9ImZpbGw6IzhhMDA1MTtmaWxsLXJ1bGU6ZXZlbm9kZCIKICAgICBpZD0icG9seWdvbjMwNzIiCiAgICAgcG9pbnRzPSI2NC44MjcsMjUuNDk0IDc5LjMyNywyNS40OTQgNzkuMzI3LDI1LjQ5NCA3OS4zMjcsMjguMDA2IDY3LjkyOSw0My4yMTQgNzkuNjEzLDQzLjIxNCA3OS42MTMsNDUuNjMgNjQuODE4LDQ1LjYzIDY0LjgxOCw0My4wMTQgNzYuMjcyLDI3Ljk3NyA2NC44MjcsMjcuOTc3ICIKICAgICBjbGlwLXJ1bGU9ImV2ZW5vZGQiIC8+PHBhdGgKICAgICBzdHlsZT0iZmlsbDojOGEwMDUxO2ZpbGwtcnVsZTpldmVub2RkIgogICAgIGlua3NjYXBlOmNvbm5lY3Rvci1jdXJ2YXR1cmU9IjAiCiAgICAgaWQ9InBhdGgzMDc0IgogICAgIGQ9Im0gOTguMjg5LDMwLjQyMSB2IDIuMjI1IGMgMS40MywtMi41IDMuODY2LC0yLjcyNyA0Ljc3NSwtMi43MjcgMS45NDksMCA0LjI4NCwwLjk3NSA1LjAyOSwzLjUwMiAwLjI2MSwwLjkwNCAwLjI2MSwxLjg0MSAwLjI2MSwzLjEzNCB2IDkuMDc1IGggLTIuNTYyIHYgLTguNjU1IGMgMCwtMS41NTIgMCwtMi4wMDMgLTAuMTYzLC0yLjUyMSAtMC40NTQsLTEuNDUzIC0xLjg4MywtMi4wOTkgLTMuMjgsLTIuMDk5IC0xLjEzNiwwIC0yLjExMSwwLjM1NSAtMi45MjQsMS4xNjIgLTEuMTM3LDEuMTMxIC0xLjEzNywyLjI5MiAtMS4xMzcsMy40MjYgdiA4LjY4NyBoIC0yLjU3IFYgMzAuNDIxIGggMi41NzEgbCAwLDAgeiIKICAgICBjbGlwLXJ1bGU9ImV2ZW5vZGQiIC8+PHBhdGgKICAgICBzdHlsZT0iZmlsbDojOGEwMDUxO2ZpbGwtcnVsZTpldmVub2RkIgogICAgIGlua3NjYXBlOmNvbm5lY3Rvci1jdXJ2YXR1cmU9IjAiCiAgICAgaWQ9InBhdGgzMDc2IgogICAgIGQ9Im0gMTM3LjkwNyw0Mi45MTkgYyAtMC45NTksMS41MDYgLTIuNzAxLDMuMDIyIC01LjgzNywzLjAyMiAtNS40MTIsMCAtNy40NTYsLTQuMTcxIC03LjQ1NiwtNy45MTggMCwtNC4zMjkgMi4zNTUsLTguMjUyIDcuMjMsLTguMjUyIDEuOTEyLDAgNC41OSwwLjU3NiA2LjA3MiwzLjA0NSBsIC0yLjQwOCwxLjAwNSBjIC0wLjQ1NSwtMS4wMDMgLTEuNDM1LC0yLjE2MiAtMy41NjcsLTIuMTYyIC00LjIyNCwwIC00LjQ3MSw0LjgxMyAtNC40NzEsNi4xNzEgMCw1LjA0NiAyLjg5OSw2LjEzNyA0LjYzMSw2LjEzNyAxLjk4MywwIDIuOTk2LC0wLjk1MSAzLjUzMSwtMS45OTkgbCAyLjI3NSwwLjk1MSAwLDAgeiIKICAgICBjbGlwLXJ1bGU9ImV2ZW5vZGQiIC8+PHBhdGgKICAgICBzdHlsZT0iZmlsbDojOGEwMDUxO2ZpbGwtcnVsZTpldmVub2RkIgogICAgIGlua3NjYXBlOmNvbm5lY3Rvci1jdXJ2YXR1cmU9IjAiCiAgICAgaWQ9InBhdGgzMDc4IgogICAgIGQ9Im0gODMuMzA1LDM2LjQwNSBoIDguMTIxIGMgLTAuMjI3LC00LjAwNiAtMi41MzYsLTQuNjgzIC00LjA3NiwtNC42ODMgLTIuMTk4LDEwZS00IC0zLjc1NSwxLjYxNCAtNC4wNDUsNC42ODMgbCAwLDAgeiBtIDEwLjIzNSw2LjMxNiBjIC0wLjg3NiwxLjQ5MSAtMi41NjcsMy4yMDIgLTUuOTAxLDMuMjAyIC00LjUyLDAgLTcuMTIsLTMuMDcyIC03LjEyLC04LjIyMiAwLC01Ljc1MyAzLjc5NSwtNy45NTIgNy4wMjUsLTcuOTUyIDIuODA4LDAgNS41LDEuNTUyIDYuNDA1LDUuMzk2IDAuMjkyLDEuMjkzIDAuMjkyLDIuNDU5IDAuMjkyLDMuMTA2IGggLTExIGMgLTAuMDY0LDIuNTU4IDEuMDA4LDUuNzk1IDQuNjI1LDUuNzMyIDEuNDc2LC0wLjAyNSAyLjUxNSwtMC42OTUgMy4xNzgsLTEuNzQ1IGwgMi40OTYsMC40ODMgMCwwIHoiCiAgICAgY2xpcC1ydWxlPSJldmVub2RkIiAvPjxwYXRoCiAgICAgc3R5bGU9ImZpbGw6IzhhMDA1MTtmaWxsLXJ1bGU6ZXZlbm9kZCIKICAgICBpbmtzY2FwZTpjb25uZWN0b3ItY3VydmF0dXJlPSIwIgogICAgIGlkPSJwYXRoMzA4MCIKICAgICBkPSJtIDExMi41MTgsMzYuNDA1IGggOC4xMjIgYyAtMC4yMjYsLTQuMDA2IC0yLjUzNSwtNC42ODMgLTQuMDc2LC00LjY4MyAtMi4xOTYsMTBlLTQgLTMuNzU0LDEuNjE0IC00LjA0Niw0LjY4MyBsIDAsMCB6IG0gMTAuMjM3LDYuMzE2IGMgLTAuODc2LDEuNDkxIC0yLjU2NiwzLjIwMiAtNS45LDMuMjAyIC00LjUyLDAgLTcuMTIxLC0zLjA3MiAtNy4xMjEsLTguMjIyIDAsLTUuNzUzIDMuNzk1LC03Ljk1MiA3LjAyNCwtNy45NTIgMi44MDksMCA1LjQ5OSwxLjU1MiA2LjQwNSw1LjM5NiAwLjI5MSwxLjI5MyAwLjI5MSwyLjQ1OSAwLjI5MSwzLjEwNiBoIC0xMSBjIC0wLjA2NSwyLjU1OCAxLjAxMSw1Ljc5NSA0LjYyNSw1LjczMiAxLjQ3NiwtMC4wMjUgMi41MTgsLTAuNjk1IDMuMTc5LC0xLjc0NSBsIDIuNDk3LDAuNDgzIDAsMCB6IgogICAgIGNsaXAtcnVsZT0iZXZlbm9kZCIgLz48cGF0aAogICAgIHN0eWxlPSJmaWxsOiM4YTAwNTE7ZmlsbC1ydWxlOmV2ZW5vZGQiCiAgICAgaW5rc2NhcGU6Y29ubmVjdG9yLWN1cnZhdHVyZT0iMCIKICAgICBpZD0icGF0aDMwODIiCiAgICAgZD0ibSAxNTEuOTUxLDQ1LjY0NiAtMi42NzIsMC4wMSBjIDAsMCAtMC4yMzEsLTEuMDc5IC0wLjMwNiwtMi4yNTcgLTAuNzc2LDAuODA2IC0yLjIxNiwyLjQ3MyAtNS4xMjYsMi40NzMgLTIuOTc2LDAgLTUuMTg0LC0xLjc2NSAtNS4xODQsLTQuMzUxIDAsLTAuODExIDAuMjI3LC0xLjYxOCAwLjY4MSwtMi4zIDAuODc3LC0xLjI5NSAyLjUsLTIuMzMxIDcuMDU5LC0yLjY4NiBsIDIuNDIzLC0wLjE5NCB2IC0wLjM4OSBjIDAsLTEuNTg2IDAsLTQuMjM5IC0zLjQxNiwtNC4yMzkgLTIuMTQ5LDAgLTIuODgxLDEuMDQyIC0zLjEyOSwxLjk4MyBsIC0yLjM2NiwtMC45ODggYyAwLjAzNywtMC4wODIgMC4wOCwtMC4xNjYgMC4xMjUsLTAuMjUxIDAuOTA5LC0xLjY4MiAyLjY5MiwtMi43MTggNS4yNzEsLTIuNzE4IDEuNDIsMCAzLjI1OCwwLjM1NyA0LjQ1NiwxLjI5NSAxLjcwNSwxLjI5MiAxLjY2NCwzLjgzNyAxLjY2NCwzLjgzNyBsIDAuMTAzLDcuODU0IGMgMCwwLjAwMiAwLjA5MSwyLjI4MiAwLjQxNywyLjkyMSBsIDAsMCB6IG0gLTMuNTEzLC00LjIyMiBjIDAuMzg4LC0wLjg0MSAwLjQyMSwtMS4xOTcgMC40MjEsLTMuNDMzIC0xLDAuMTYyIC0yLjM1MywwLjM1NiAtNC4wMDksMC43MTMgLTIuODQ2LDAuNjE0IC0zLjMzMSwxLjY4NiAtMy4zMzEsMi43NTMgMCwxLjIzIDAuOTcxLDIuMjY3IDIuODc4LDIuMjY3IDEuNzgsMCAzLjI5OSwtMC43MTIgNC4wNDEsLTIuMyBsIDAsMCB6IgogICAgIGNsaXAtcnVsZT0iZXZlbm9kZCIgLz48cGF0aAogICAgIHN0eWxlPSJmaWxsOiM4YTAwNTE7ZmlsbC1ydWxlOmV2ZW5vZGQiCiAgICAgaW5rc2NhcGU6Y29ubmVjdG9yLWN1cnZhdHVyZT0iMCIKICAgICBpZD0icGF0aDMwODQiCiAgICAgZD0ibSA2My4wMDQsNDUuNjQ2IC0yLjY3MiwwLjAxIGMgMCwwIC0wLjIzMiwtMS4wNzkgLTAuMzA2LC0yLjI1NyAtMC43NzYsMC44MDYgLTIuMjE0LDIuNDczIC01LjEyNSwyLjQ3MyAtMi45NzgsMCAtNS4xODUsLTEuNzY1IC01LjE4NSwtNC4zNTEgMCwtMC44MTEgMC4yMjcsLTEuNjE4IDAuNjgyLC0yLjMgMC44NzcsLTEuMjk1IDIuNDk5LC0yLjMzMSA3LjA1NiwtMi42ODYgbCAyLjQyNiwtMC4xOTQgdiAtMC4zODkgYyAwLC0xLjU4NiAwLC00LjIzOSAtMy40MTgsLTQuMjM5IC0yLjE0OSwwIC0yLjg3OSwxLjA0MiAtMy4xMjksMS45ODMgbCAtMi4zNjYsLTAuOTg4IGMgMC4wMzksLTAuMDgyIDAuMDgsLTAuMTY2IDAuMTI2LC0wLjI1MSAwLjkwOSwtMS42ODIgMi42OTMsLTIuNzE4IDUuMjcsLTIuNzE4IDEuNDE5LDAgMy4yNTksMC4zNTcgNC40NTYsMS4yOTUgMS43MDUsMS4yOTIgMS42NjQsMy44MzcgMS42NjQsMy44MzcgbCAwLjEwMyw3Ljg1NCBjIDAsMC4wMDIgMC4wOTEsMi4yODIgMC40MTgsMi45MjEgbCAwLDAgeiBtIC0zLjUxMywtNC4yMjIgYyAwLjM5LC0wLjg0MSAwLjQyLC0xLjE5NyAwLjQyLC0zLjQzMyAtMC45OTgsMC4xNjIgLTIuMzUzLDAuMzU2IC00LjAwNywwLjcxMyAtMi44NDQsMC42MTQgLTMuMzMsMS42ODYgLTMuMzMsMi43NTMgMCwxLjIzIDAuOTY5LDIuMjY3IDIuODc2LDIuMjY3IDEuNzc5LDAgMy4yOTgsLTAuNzEyIDQuMDQxLC0yLjMgbCAwLDAgeiIKICAgICBjbGlwLXJ1bGU9ImV2ZW5vZGQiIC8+PC9nPgoKPC9zdmc+",
    "carleton.svg": "PHN2ZyB3aWR0aD0iMTQ5IiBoZWlnaHQ9IjQwIiB2aWV3Qm94PSIwIDAgMTQ5IDQwIiBmaWxsPSJub25lIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgo8cGF0aCBkPSJNMTYuNTQ0OSA3LjI0NDFMMTMuNTQzOSA3LjI1Mjc1TDEzLjEyMTMgNC41NzEzOEMxMi43MjM2IDQuMTc2MTYgMTIuMjIyMiAzLjg2NDE0IDExLjYxOCAzLjYzNTMzQzExLjAxMzUgMy40MDY4NyAxMC4zMDA4IDMuMjkzNTEgOS40ODA0MiAzLjI5NTg1QzcuNzI4NjEgMy4zMDA5OSA2LjM4MjExIDMuOTQxMTUgNS40NDEwMiA1LjIxNjM0QzQuNDk5NjUgNi40OTE1MiA0LjAzMjE2IDguMTUyMzQgNC4wMzgxIDEwLjE5ODlMNC4wNDAyIDEwLjkwNDNDNC4wNDYzNiAxMi45NTEgNC41MjEzNyAxNC42MTM4IDUuNDY1NTcgMTUuODkyMUM2LjQwOTc3IDE3LjE3MTUgNy43MzkyNCAxNy44MDc5IDkuNDU0MjIgMTcuODAyOEMxMC4yNDcgMTcuODAwOCAxMC45NzI2IDE3LjY4MzMgMTEuNjMxMiAxNy40NTA4QzEyLjI4OTUgMTcuMjE4OCAxMi43OTgyIDE2LjkwMzcgMTMuMTU2NSAxNi41MDU5TDEzLjU2MzUgMTMuODIxN0wxNi41NjQ1IDEzLjgxM0wxNi41NzYzIDE3Ljc5NTdDMTUuNzY3NSAxOC43Mzg2IDE0LjczNSAxOS40OTA0IDEzLjQ3ODIgMjAuMDUyMUMxMi4yMjEzIDIwLjYxMzMgMTAuODEzOSAyMC44OTY4IDkuMjU1NzggMjAuOTAxNkM2LjU1NDU3IDIwLjkwOTUgNC4zMzkwMSAxOS45ODAzIDIuNjA5MzggMTguMTEzNkMwLjg4MDAzNSAxNi4yNDcgMC4wMTA2OTczIDEzLjg0ODEgMC4wMDIyMTMyNiAxMC45MTYxTDYuMzAyNzNlLTA1IDEwLjIzODdDLTAuMDA4NDMyNzMgNy4zMTYwOSAwLjg0MTk2MSA0LjkxMTggMi41NTEwNSAzLjAyNjAyQzQuMjYwMzUgMS4xNDAwMSA2LjQ3NDczIDAuMTkzMzIxIDkuMTk0NjEgMC4xODUyNTdDMTAuNzUyNSAwLjE4MDQ2NiAxMi4xNTk1IDAuNDU5NzYzIDEzLjQxNDkgMS4wMjMzOEMxNC42NzAyIDEuNTg2NTMgMTUuNzA5OCAyLjMzMjQ1IDE2LjUzMzEgMy4yNjEzOEwxNi41NDQ5IDcuMjQ0MVpNMjQuMDg2IDE3Ljk1MThDMjQuNjc3NyAxNy45NSAyNS4yMTU2IDE3LjgyMDkgMjUuNjk4OSAxNy41NjQxQzI2LjE4MjQgMTcuMzA2NiAyNi41NTgxIDE2Ljk4NSAyNi44MjU5IDE2LjU5ODZMMjYuODE5MyAxNC4zNzlMMjQuODE1MSAxNC4zODVDMjMuOTgxMyAxNC4zODc4IDIzLjM0OTcgMTQuNTg0OSAyMi45MjAyIDE0Ljk3NTVDMjIuNDkxIDE1LjM2NyAyMi4yNzcxIDE1LjgzNjYgMjIuMjc4OCAxNi4zODM1QzIyLjI4MDMgMTYuODc3IDIyLjQ0MDUgMTcuMjYxNiAyMi43NTk5IDE3LjUzODdDMjMuMDc4OCAxNy44MTU4IDIzLjUyMSAxNy45NTM3IDI0LjA4NiAxNy45NTE4Wk0yNy40OTY4IDIwLjU2NDdDMjcuMzg4NCAyMC4zMjMgMjcuMjkzNSAyMC4wNzQzIDI3LjIxMjIgMTkuODE4OUMyNy4xMzA2IDE5LjU2MzQgMjcuMDY3IDE5LjMwNjYgMjcuMDIxNCAxOS4wNDZDMjYuNTU2NyAxOS41ODU1IDI1Ljk5MDcgMjAuMDIyNCAyNS4zMjM4IDIwLjM1NjFDMjQuNjU2OCAyMC42ODkzIDIzLjg5MjkgMjAuODU3OSAyMy4wMzE5IDIwLjg2MDdDMjEuNjA2MiAyMC44NjQ4IDIwLjQ3MjggMjAuNDgwMiAxOS42MzIxIDE5LjcwNzNDMTguNzkxMiAxOC45MzM5IDE4LjM2OTEgMTcuODc5MiAxOC4zNjQ5IDE2LjU0MjlDMTguMzYxIDE1LjE4IDE4LjkwNDkgMTQuMTI0OCAxOS45OTY3IDEzLjM3NzNDMjEuMDg4NSAxMi42Mjk2IDIyLjY5MjYgMTIuMjUyNyAyNC44MDg5IDEyLjI0NjNMMjYuODEzMSAxMi4yNDA0TDI2LjgwODggMTAuODE0NUMyNi44MDY3IDEwLjExNSAyNi42MDMzIDkuNTczMjUgMjYuMTk4NyA5LjE4ODg5QzI1Ljc5NDEgOC44MDQ1NCAyNS4xOTcxIDguNjEzMzYgMjQuNDA4MiA4LjYxNTU4QzIzLjk1OTcgOC42MTY5OCAyMy41NjA5IDguNjcwMTUgMjMuMjExMyA4Ljc3NDE1QzIyLjg2MTkgOC44NzgyOCAyMi41Nzk3IDkuMDAyNSAyMi4zNjUxIDkuMTQ2NTlMMjIuMTE0IDEwLjcwNzZMMTkuMTU0OSAxMC43MTY0TDE5LjE1ODcgNy40ODc5OUMxOS44NzQ3IDcuMDAxNzMgMjAuNjk2NCA2LjU5MTIgMjEuNjIzNCA2LjI1NjYzQzIyLjU1MDUgNS45MjI0MSAyMy41NjExIDUuNzUzMTkgMjQuNjU1MSA1Ljc1MDA0QzI2LjQ1NzcgNS43NDQ3OCAyNy45MjI3IDYuMTgyMTkgMjkuMDUwNyA3LjA2MThDMzAuMTc4NyA3Ljk0MTk5IDMwLjc0NTMgOS4xOTgxMyAzMC43NTAxIDEwLjgzMDFMMzAuNzY3OCAxNi44NDI2QzMwLjc2ODUgMTcuMDY2OCAzMC43NzEzIDE3LjI3NzcgMzAuNzc2NSAxNy40NzQ5QzMwLjc4MTMgMTcuNjcyIDMwLjc5NzcgMTcuODYwNCAzMC44MjUzIDE4LjAzOTZMMzIuMDIyNyAxOC4xOTc3TDMyLjAyOTkgMjAuNTUxNEwyNy40OTY4IDIwLjU2NDdaTTMzLjM5ODggMTguMTkyNkwzNS4yODA3IDE3Ljc4MzJMMzUuMjU0IDguNzU3OTFMMzMuMTY4MSA4LjM2MDM1TDMzLjE2MDkgNS45OTMxMUwzOC45MDQ1IDUuOTc2MTdMMzkuMDg1NSA4LjEwMDgxQzM5LjQyNCA3LjM0NjcxIDM5Ljg2MiA2Ljc1Nzk2IDQwLjM5ODcgNi4zMzQ4MUM0MC45MzU0IDUuOTExNzcgNDEuNTU4MSA1LjY5OTMyIDQyLjI2NjQgNS42OTcyMkM0Mi40NzI3IDUuNjk2NTEgNDIuNjkwMSA1LjcxMTU5IDQyLjkxODkgNS43NDI0NEM0My4xNDc3IDUuNzczMTggNDMuMzM4MiA1LjgxMDY5IDQzLjQ5MTEgNS44NTQ3NUw0My4wODQ2IDkuNDM0M0w0MS40NzAzIDkuMzk4NDNDNDAuODk2MyA5LjQwMDMgNDAuNDIxNCA5LjUxNCA0MC4wNDU1IDkuNzM5MTlDMzkuNjY5NCA5Ljk2NDYxIDM5LjM4MzMgMTAuMjgzNSAzOS4xODczIDEwLjY5NjlMMzkuMjA4MiAxNy43NzE3TDQxLjA5MjcgMTguMTcwMUw0MS4wOTk2IDIwLjUyMzhMMzMuNDA1OCAyMC41NDYzTDMzLjM5ODggMTguMTkyNlpNNDMuOTk4MSAyLjQ0ODAzTDQzLjk5MSAwLjA4MDU1MTFMNTAuMDE3IDAuMDYyOTA0NEw1MC4wNzEgMTcuNzQwOUw1MS45Njg4IDE4LjEzOTRMNTEuOTc1NyAyMC40OTNMNDQuMjU1IDIwLjUxNTVMNDQuMjQ3OCAxOC4xNjE4TDQ2LjE0MzIgMTcuNzUyNEw0Ni4wOTc1IDIuODQ1MjRMNDMuOTk4MSAyLjQ0ODAzWk01OS43NDUyIDguNjczMDdDNTkuMDE4OSA4LjY3NTE3IDU4LjQ0NTYgOC45NTQ3MSA1OC4wMjU4IDkuNTEyMTNDNTcuNjA2MSAxMC4wNjkzIDU3LjM0OCAxMC44MDA4IDU3LjI1MjIgMTEuNzA2OUw1Ny4yOTI2IDExLjc3MzdMNjIuMTA4MSAxMS43NTk1TDYyLjEwNzIgMTEuNDA5OEM2Mi4xMDQ2IDEwLjU3NjEgNjEuOTA3NyA5LjkxMDg2IDYxLjUxNjIgOS40MTQzMkM2MS4xMjQ3IDguOTE3NzggNjAuNTM0MiA4LjY3MDUgNTkuNzQ1MiA4LjY3MzA3Wk01OS43NDU0IDIwLjc1MTNDNTcuNjQ3IDIwLjc1NzMgNTUuOTY3OCAyMC4wODk1IDU0LjcwODcgMTguNzQ4MkM1My40NDkyIDE3LjQwNjkgNTIuODE2NCAxNS43MDAxIDUyLjgxMDUgMTMuNjI5MUw1Mi44MDg4IDEzLjA5MUM1Mi44MDI0IDEwLjkyOTggNTMuMzkxIDkuMTQ3NzYgNTQuNTc1MyA3Ljc0NTU1QzU1Ljc1OTIgNi4zNDMzNCA1Ny4zNTEgNS42NDM0NiA1OS4zNTA5IDUuNjQ2NjJDNjEuMzE0NiA1LjY0MDY2IDYyLjg0MDcgNi4yMjgxMiA2My45Mjk0IDcuNDA4NjRDNjUuMDE3NyA4LjU4ODkzIDY1LjU2NTMgMTAuMTg4MiA2NS41NzEzIDEyLjIwNTlMNjUuNTc3NSAxNC4zNDQ1TDU2Ljg4ODMgMTQuMzcwM0w1Ni44NjE0IDE0LjQ1MDdDNTYuOTM2MSAxNS40MTAyIDU3LjI1ODkgMTYuMTk4MyA1Ny44MzAzIDE2LjgxNTRDNTguNDAxNSAxNy40MzI2IDU5LjE3NTggMTcuNzM5NiA2MC4xNTMyIDE3LjczNjhDNjEuMDIzMSAxNy43MzQgNjEuNzQ0OCAxNy42NDQ5IDYyLjMxOCAxNy40NjhDNjIuODkxNSAxNy4yOTE1IDYzLjUxODMgMTcuMDE0IDY0LjE5ODkgMTYuNjM1Mkw2NS4yNjg2IDE5LjA1MzNDNjQuNjY5MiAxOS41MzAzIDYzLjg5MjYgMTkuOTMxNSA2Mi45Mzg0IDIwLjI1NzNDNjEuOTg0NSAyMC41ODI3IDYwLjkxOTkgMjAuNzQ3NiA1OS43NDU0IDIwLjc1MTNaTTcyLjAzOTMgMS45NjE0Mkw3Mi4wNDk4IDUuODc0NjFMNzQuNjA1NSA1Ljg2NzAyTDc0LjYxMzggOC42MjQzNEw3Mi4wNTgxIDguNjMxOTRMNzIuMDc5OSAxNi4wNDM5QzcyLjA4MTYgMTYuNjA4NiA3Mi4xOTk0IDE3LjAxMTcgNzIuNDMzMyAxNy4yNTI5QzcyLjY2NjkgMTcuNDk0NiA3Mi45ODEzIDE3LjYxNDUgNzMuMzc1OCAxNy42MTMxQzczLjY0NDggMTcuNjEyNyA3My44ODA0IDE3LjYwMDcgNzQuMDgxOSAxNy41Nzc3Qzc0LjI4MzggMTcuNTU0OCA3NC41MDk5IDE3LjUxNTggNzQuNzYwOCAxNy40NjExTDc1LjEwNTUgMjAuMjk4NkM3NC42NjY2IDIwLjQzNDEgNzQuMjMxOSAyMC41MzY2IDczLjgwMTggMjAuNjA1MUM3My4zNzE1IDIwLjY3MzYgNzIuOTA1MiAyMC43MDg1IDcyLjQwMzIgMjAuNzEwNEM3MS4wNDkgMjAuNzE0IDcwLjAwNTQgMjAuMzQ1MSA2OS4yNzI1IDE5LjYwMjlDNjguNTM5MyAxOC44NjA3IDY4LjE3MDUgMTcuNjgyNiA2OC4xNjU3IDE2LjA2ODdMNjguMTQzOCA4LjY0MzYyTDY2Ljc3NzkgOC42NDk4Mkw2Ni43Njk2IDUuODkyNDlMNjguMTM1NSA1Ljg4NjNMNjguMTI1IDEuOTczMjJMNzIuMDM5MyAxLjk2MTQyWk03OS44MjUzIDEzLjI3NTdDNzkuODI5MiAxNC42MDI4IDgwLjA2NTUgMTUuNjY3NSA4MC41MzQxIDE2LjQ2ODVDODEuMDAyOCAxNy4yNjk5IDgxLjc1NzIgMTcuNjY4OCA4Mi43OTc2IDE3LjY2NTZDODMuODEwOCAxNy42NjIzIDg0LjU1MTggMTcuMjU3MSA4NS4wMiAxNi40NDgzQzg1LjQ4ODUgMTUuNjM5OSA4NS43MjA4IDE0LjU3NjYgODUuNzE2OSAxMy4yNTgyTDg1LjcxNiAxMi45NzU2Qzg1LjcxMjEgMTEuNjg0MyA4NS40NzEzIDEwLjYzMTggODQuOTkzNiA5LjgxNjc4Qzg0LjUxNiA5LjAwMjI3IDgzLjc2NiA4LjU5NjUzIDgyLjc0MzggOC41OTk1N0M4MS43MjE1IDguNjAyNDkgODAuOTc4MyA5LjAxMjkgODAuNTE0NiA5LjgzMDExQzgwLjA1MDUgMTAuNjQ3OSA3OS44MjA1IDExLjcwMTkgNzkuODI0NCAxMi45OTMxTDc5LjgyNTMgMTMuMjc1N1pNNzUuODk2OCAxMy4wMDQ5Qzc1Ljg5MDQgMTAuODM1IDc2LjQ5MjYgOS4wNTU0NCA3Ny43MDM1IDcuNjY2MzJDNzguOTE0NSA2LjI3NzMxIDgwLjU5MTYgNS41Nzk1NCA4Mi43MzQ4IDUuNTczMTFDODQuODg3IDUuNTY2OTIgODYuNTcyNSA2LjI1MjU0IDg3Ljc5MiA3LjYyOTUxQzg5LjAxMSA5LjAwNzE4IDg5LjYyMzkgMTAuNzg1NiA4OS42MzAzIDEyLjk2NDJMODkuNjMxMiAxMy4yNDY4Qzg5LjYzNzYgMTUuNDM1IDg5LjAzNTEgMTcuMjE4OCA4Ny44MjQzIDE4LjU5OTNDODYuNjEzMiAxOS45Nzg5IDg0Ljk0MDYgMjAuNjcyMiA4Mi44MDY2IDIwLjY3ODZDODAuNjQ1MyAyMC42ODUgNzguOTU1MiAyMC4wMDE4IDc3LjczNjEgMTguNjI5MkM3Ni41MTY4IDE3LjI1NTcgNzUuOTA0IDE1LjQ3NTQgNzUuODk3NSAxMy4yODc0TDc1Ljg5NjggMTMuMDA0OVpNOTAuNjM0OCAxOC4wMTc2TDkyLjUxNjcgMTcuNjA4MUw5Mi40OTAxIDguNTgyNzRMOTAuNDA0MSA4LjE4NTNMOTAuMzk3IDUuODE4MDVMOTYuMTQwNiA1LjgwMDk5TDk2LjMyMTUgNy44ODU0M0M5Ni44MDM0IDcuMTM5ODYgOTcuMzk4MSA2LjU1OTUzIDk4LjEwNTYgNi4xNDUwM0M5OC44MTI1IDUuNzMwNTIgOTkuNjA1NCA1LjUyMTkzIDEwMC40ODUgNS41MTkxMkMxMDEuOTU1IDUuNTE0OCAxMDMuMTA0IDUuOTczMzYgMTAzLjkzMiA2Ljg5NDQ1QzEwNC43NiA3LjgxNTU1IDEwNS4xNzYgOS4yNjI2MyAxMDUuMTgyIDExLjIzNTZMMTA1LjIwMSAxNy41NzA1TDEwNy4wODUgMTcuOTY4OUwxMDcuMDkzIDIwLjMyMjVMOTkuNTg2OCAyMC4zNDUxTDk5LjU3OTcgMTcuOTkxNEwxMDEuMjYgMTcuNTgyNEwxMDEuMjQxIDExLjI2MDdDMTAxLjIzOCAxMC4yODMzIDEwMS4wMzkgOS41OTEwMSAxMDAuNjQzIDkuMTg0MUMxMDAuMjQ3IDguNzc3MTkgOTkuNjUwNSA4LjU3NDkxIDk4Ljg1MjMgOC41NzcyNUM5OC4zMzIzIDguNTc4ODggOTcuODY2MSA4LjY4NTY5IDk3LjQ1NDcgOC44OTc1NkM5Ny4wNDI0IDkuMTA5NjYgOTYuNjk4MiA5LjQwODgzIDk2LjQyMTQgOS43OTUyOEw5Ni40NDQzIDE3LjU5NjdMOTguMDMyOSAxNy45OTZMOTguMDM5OCAyMC4zNDk3TDkwLjY0MTkgMjAuMzcxM0w5MC42MzQ4IDE4LjAxNzZaTTM2LjU1OTYgMjYuMDM3MUwzNi41NjM1IDI3LjM1MzFMMzUuMzk3NSAyNy41ODEzTDM1LjQxNDQgMzMuMjY0OEMzNS40MTY1IDMzLjk4MzEgMzUuNjExMiAzNC41MTk2IDM1Ljk5ODYgMzQuODc1MUMzNi4zODYxIDM1LjIzMDIgMzYuOTE2NCAzNS40MDY1IDM3LjU4OTQgMzUuNDA0M0MzOC4yNzI0IDM1LjQwMjYgMzguODA3OCAzNS4yMjQyIDM5LjE5NTYgMzQuODY4OEMzOS41ODM1IDM0LjUxNDEgMzkuNzc2NCAzMy45NzQ2IDM5Ljc3NDMgMzMuMjUxN0wzOS43NTc1IDI3LjU2ODFMMzguNTk3NSAyNy4zNDcxTDM4LjU5MzggMjYuMDMxMkw0My4xMDMxIDI2LjAxOEw0My4xMDY5IDI3LjMzMzlMNDEuOTQxIDI3LjU2MThMNDEuOTU3OSAzMy4yNDUzQzQxLjk2MTUgMzQuNDY2OCA0MS41NjE2IDM1LjQxMDcgNDAuNzU4NCAzNi4wNzU3QzM5Ljk1NTIgMzYuNzQxMiAzOC45MDA1IDM3LjA3NTkgMzcuNTk0NCAzNy4wNzk3QzM2LjI5MzIgMzcuMDg0IDM1LjI0MTUgMzYuNzU1MiAzNC40MzkzIDM2LjA5NDVDMzMuNjM3MyAzNS40MzQxIDMzLjIzNDMgMzQuNDkyOCAzMy4yMzA3IDMzLjI3MTNMMzMuMjEzOSAyNy41ODc4TDMyLjA1NCAyNy4zNjY4TDMyLjA1MDIgMjYuMDUwN0wzMy4yMDkzIDI2LjA0NzNMMzUuMzkzIDI2LjA0MUwzNi41NTk2IDI2LjAzNzFaTTQzLjcwNzMgMzUuNTk1OUw0NC43NTM1IDM1LjM2ODZMNDQuNzM4NyAzMC4zNTA5TDQzLjU3ODkgMzAuMTI5OUw0My41NzUxIDI4LjgxMzVMNDYuNzY4MyAyOC44MDQyTDQ2Ljg2ODkgMjkuOTYzMUM0Ny4xMzY5IDI5LjU0ODMgNDcuNDY3NCAyOS4yMjYgNDcuODYwNyAyOC45OTUzQzQ4LjI1MzggMjguNzY0NSA0OC42OTQ2IDI4LjY0ODcgNDkuMTgzMyAyOC42NDc0QzUwLjAwMDkgMjguNjQ0OSA1MC42Mzk5IDI4LjkgNTEuMTAwMSAyOS40MTE3QzUxLjU2MDIgMjkuOTIzOSA1MS43OTE5IDMwLjcyODYgNTEuNzk1MiAzMS44MjU0TDUxLjgwNTYgMzUuMzQ3N0w1Mi44NTMyIDM1LjU2ODZMNTIuODU3IDM2Ljg3NzVMNDguNjg0MiAzNi44ODk5TDQ4LjY4MDQgMzUuNTgxTDQ5LjYxNDYgMzUuMzU0MUw0OS42MDQgMzEuODM5NEM0OS42MDI1IDMxLjI5NjEgNDkuNDkxNiAzMC45MTEzIDQ5LjI3MTYgMzAuNjg0OEM0OS4wNTE1IDMwLjQ1OTEgNDguNzE5NiAzMC4zNDYzIDQ4LjI3NiAzMC4zNDc1QzQ3Ljk4NjggMzAuMzQ4NCA0Ny43Mjc2IDMwLjQwOCA0Ny40OTg3IDMwLjUyNkM0Ny4yNjk3IDMwLjY0MzQgNDcuMDc4MiAzMC44MSA0Ni45MjQ0IDMxLjAyNUw0Ni45MzczIDM1LjM2MjFMNDcuODIwMyAzNS41ODM2TDQ3LjgyNDEgMzYuODkyM0w0My43MTExIDM2LjkwNDdMNDMuNzA3MyAzNS41OTU5Wk01Ni42OTM3IDI2LjgzOEw1NC41MTAxIDI2Ljg0NDRMNTQuNTA1MiAyNS4yMDY1TDU2LjY4ODggMjUuMjAwMUw1Ni42OTM3IDI2LjgzOFpNNTMuNDgxMyAzNS41NjdMNTQuNTM1MiAzNS4zMzk2TDU0LjUyMDIgMzAuMzIxOUw1My4zNTMgMzAuMTAwOUw1My4zNDkyIDI4Ljc4NDVMNTYuNjk5NSAyOC43NzQ3TDU2LjcxODkgMzUuMzMzM0w1Ny43NjY1IDM1LjU1NDFMNTcuNzcwMiAzNi44NjNMNTMuNDg1MiAzNi44NzU3TDUzLjQ4MTMgMzUuNTY3Wk02MS41NjU0IDMwLjA3NTVMNjAuODAzIDMwLjIxOThMNjEuODgzMiAzMy44MzYzTDYyLjAyNzUgMzQuNTk4M0g2Mi4wNzI1TDYyLjIyNzIgMzMuODM1NEw2My4yNzA5IDMwLjIyMDNMNjIuNDkyOCAzMC4wNzI5TDYyLjQ4OSAyOC43NTY1TDY2LjE2MDcgMjguNzQ1NEw2Ni4xNjQ2IDMwLjA2MThMNjUuNDYxOSAzMC4xNzZMNjMuMDk2MSAzNi44NDY0TDYxLjAwOTYgMzYuODUyM0w1OC41OTY4IDMwLjE5NjRMNTcuODkzNSAzMC4wODY2TDU3Ljg4OTggMjguNzcwMUw2MS41NjE3IDI4Ljc1OTFMNjEuNTY1NCAzMC4wNzU1Wk03MC4xMDc2IDMwLjI2NjJDNjkuNzAzNyAzMC4yNjc1IDY5LjM4NSAzMC40MjI5IDY5LjE1MTggMzAuNzMyNUM2OC45MTgzIDMxLjA0MjQgNjguNzc0OSAzMS40NDkgNjguNzIxNiAzMS45NTI2TDY4Ljc0NDIgMzEuOTkwMUw3MS40MjEzIDMxLjk4MjRMNzEuNDIwOCAzMS43ODc5QzcxLjQxOTQgMzEuMzI0MyA3MS4zMDk4IDMwLjk1NDMgNzEuMDkyMiAzMC42Nzg0QzcwLjg3NDUgMzAuNDAyIDcwLjU0NjEgMzAuMjY0OSA3MC4xMDc2IDMwLjI2NjJaTTcwLjMyMTkgMzYuOTgwOUM2OS4xNTU0IDM2Ljk4NDMgNjguMjIxOCAzNi42MTM1IDY3LjUyMTcgMzUuODY3NkM2Ni44MjE0IDM1LjEyMiA2Ni40Njk2IDM0LjE3MyA2Ni40NjYyIDMzLjAyMTNMNjYuNDY1NCAzMi43MjI1QzY2LjQ2MTkgMzEuNTIwOSA2Ni43ODkyIDMwLjUzMDIgNjcuNDQ3NSAyOS43NTAxQzY4LjEwNTcgMjguOTcxIDY4Ljk5MDcgMjguNTgxNCA3MC4xMDI1IDI4LjU4MzZDNzEuMTk0NCAyOC41ODAyIDcyLjA0MyAyOC45MDY4IDcyLjY0ODIgMjkuNTYyOEM3My4yNTMzIDMwLjIxOTQgNzMuNTU3NiAzMS4xMDg0IDczLjU2MDkgMzIuMjMwM0w3My41NjQ0IDMzLjQxOTVMNjguNzMzNCAzMy40MzM1TDY4LjcxODYgMzMuNDc4MUM2OC43NiAzNC4wMTE3IDY4LjkzOTQgMzQuNDUwMiA2OS4yNTcyIDM0Ljc5MjlDNjkuNTc0NyAzNS4xMzYxIDcwLjAwNTMgMzUuMzA2OCA3MC41NDg3IDM1LjMwNTFDNzEuMDMyMiAzNS4zMDM0IDcxLjQzMzUgMzUuMjU0IDcxLjc1MjMgMzUuMTU1N0M3Mi4wNzA5IDM1LjA1NzcgNzIuNDE5NSAzNC45MDMyIDcyLjc5NzggMzQuNjkyOUw3My4zOTI4IDM2LjAzN0M3My4wNTkzIDM2LjMwMjMgNzIuNjI3NSAzNi41MjU0IDcyLjA5NzEgMzYuNzA2OEM3MS41NjY4IDM2Ljg4NzcgNzAuOTc0OSAzNi45NzkzIDcwLjMyMTkgMzYuOTgwOVpNNzQuNDMxOSAzNS41MDE4TDc1LjQ3ODEgMzUuMjc0NUw3NS40NjMzIDMwLjI1NjlMNzQuMzAzNCAzMC4wMzU5TDc0LjI5OTYgMjguNzE5NEw3Ny40OTI4IDI4LjcxMDFMNzcuNTkzNCAyOS44OTExQzc3Ljc4MTcgMjkuNDcyMSA3OC4wMjUxIDI5LjE0NDggNzguMzIzNiAyOC45MDkzQzc4LjYyMiAyOC42NzQzIDc4Ljk2OCAyOC41NTYzIDc5LjM2MiAyOC41NTVDNzkuNDc2NiAyOC41NTQ3IDc5LjU5NzYgMjguNTYzMiA3OS43MjQ3IDI4LjU4MDJDNzkuODUxOSAyOC41OTc3IDc5Ljk1NzkgMjguNjE4MSA4MC4wNDI3IDI4LjY0MjhMNzkuODE2OCAzMC42MzI4TDc4LjkxOTMgMzAuNjEyOEM3OC42MDAzIDMwLjYxMzYgNzguMzM2MiAzMC42NzcxIDc4LjEyNzIgMzAuODAyMkM3Ny45MTgyIDMwLjkyNzQgNzcuNzU5IDMxLjEwNDkgNzcuNjUwMSAzMS4zMzQ0TDc3LjY2MTggMzUuMjY4TDc4LjcwOTMgMzUuNDg5NUw3OC43MTMyIDM2Ljc5ODJMNzQuNDM1NiAzNi44MTA2TDc0LjQzMTkgMzUuNTAxOFpNODYuOTY5OCAzMS40NjMxTDg1LjUwNDEgMzEuNDY3M0w4NS4yNjkyIDMwLjQ1ODdDODUuMTE5MiAzMC4zMzk1IDg0LjkzMDkgMzAuMjQwMyA4NC43MDM3IDMwLjE2MUM4NC40NzY1IDMwLjA4MTkgODQuMjI1OCAzMC4wNDI3IDgzLjk1MTggMzAuMDQzNkM4My41Njc5IDMwLjA0NDkgODMuMjY0MSAzMC4xMzE3IDgzLjA0MDMgMzAuMzA0MUM4Mi44MTY0IDMwLjQ3NyA4Mi43MDQ4IDMwLjY5MzIgODIuNzA1NiAzMC45NTI1QzgyLjcwNjMgMzEuMTk2OSA4Mi44MTQyIDMxLjM5OTcgODMuMDI5IDMxLjU2MDZDODMuMjQzNyAzMS43MjIzIDgzLjY3MyAzMS44NjQ1IDg0LjMxNjQgMzEuOTg2N0M4NS4zMTkyIDMyLjE4MzQgODYuMDYyOSAzMi40NzQyIDg2LjU0NzYgMzIuODU5MUM4Ny4wMzIyIDMzLjI0NDQgODcuMjc1NyAzMy43NzU4IDg3LjI3NzggMzQuNDUzNUM4Ny4yNzk5IDM1LjE4MTYgODYuOTY4OCAzNS43NzY5IDg2LjM0NDUgMzYuMjM5NkM4NS43MjAxIDM2LjcwMjkgODQuODk3IDM2LjkzNTggODMuODc1IDM2LjkzOTJDODMuMjUxNyAzNi45NDA5IDgyLjY3OTMgMzYuODUxNSA4Mi4xNTc5IDM2LjY3MUM4MS42MzYzIDM2LjQ5MDQgODEuMTczMiAzNi4yMzE2IDgwLjc2ODQgMzUuODkzNUw4MC43NDA2IDM0LjA3NjRMODIuMjY2MSAzNC4wNzIxTDgyLjU2ODQgMzUuMTI1OUM4Mi42OTgyIDM1LjIzNDkgODIuODc1NSAzNS4zMTUzIDgzLjEgMzUuMzY3M0M4My4zMjQ2IDM1LjQxODQgODMuNTU4OSAzNS40NDQzIDgzLjgwMzIgMzUuNDQzNUM4NC4yNDcgMzUuNDQyMiA4NC41ODQ1IDM1LjM2MTggODQuODE1OSAzNS4yMDEyQzg1LjA0NzEgMzUuMDQwOCA4NS4xNjI1IDM0LjgyNCA4NS4xNjE1IDM0LjU0OTlDODUuMTYxIDM0LjMxMDUgODUuMDQzMiAzNC4xMDM3IDg0LjgwODMgMzMuOTI5OUM4NC41NzM0IDMzLjc1NjMgODQuMTQxOCAzMy42MDI5IDgzLjUxMzIgMzMuNDdDODIuNTYwMyAzMy4yNzg1IDgxLjg0MDUgMzIuOTkyOCA4MS4zNTMyIDMyLjYxMjdDODAuODY2IDMyLjIzMjQgODAuNjIxNCAzMS43MTM4IDgwLjYxOTQgMzEuMDU1NkM4MC42MTc0IDMwLjM3NzggODAuODk1IDI5Ljc5MjQgODEuNDUxOCAyOS4yOTkzQzgyLjAwODggMjguODA2OCA4Mi44MDMzIDI4LjU1ODkgODMuODM1MyAyOC41NTZDODQuNDYzNCAyOC41NTM5IDg1LjA1ODEgMjguNjM2OCA4NS42MTk2IDI4LjgwNDVDODYuMTgxIDI4Ljk3MjggODYuNjIxNSAyOS4xODgyIDg2Ljk0MTQgMjkuNDUxM0w4Ni45Njk4IDMxLjQ2MzFaTTkxLjQwNTUgMjYuNzMxMUw4OS4yMjE3IDI2LjczNzVMODkuMjE2OCAyNS4wOTk2TDkxLjQwMDYgMjUuMDkzMUw5MS40MDU1IDI2LjczMTFaTTg4LjE5MzEgMzUuNDYwNkw4OS4yNDY5IDM1LjIzMjhMODkuMjMyIDMwLjIxNTJMODguMDY0OCAyOS45OTQyTDg4LjA2MSAyOC42Nzc3TDkxLjQxMTIgMjguNjY3OUw5MS40MzA2IDM1LjIyNjRMOTIuNDc4MiAzNS40NDc4TDkyLjQ4MiAzNi43NTY1TDg4LjE5NyAzNi43NjkzTDg4LjE5MzEgMzUuNDYwNlpNOTYuMDU4IDI2LjY3MTVMOTYuMDYzOSAyOC42NTNMOTcuNDg0OCAyOC42NDg3TDk3LjQ4OTMgMzAuMTgyTDk2LjA2ODQgMzAuMTg2Mkw5Ni4wODA2IDM0LjMwNjZDOTYuMDgxNSAzNC42MjA5IDk2LjE0NyAzNC44NDUyIDk2LjI3NyAzNC45Nzk0Qzk2LjQwNyAzNS4xMTM2IDk2LjU4MTYgMzUuMTgwNCA5Ni44MDExIDM1LjE3OTVDOTYuOTUwNyAzNS4xNzkxIDk3LjA4MTUgMzUuMTcyMiA5Ny4xOTM2IDM1LjE2Qzk3LjMwNTggMzUuMTQ3MSA5Ny40MzE3IDM1LjEyNTUgOTcuNTcxMiAzNS4wOTUyTDk3Ljc2MjggMzYuNjcyNkM5Ny41MTg3IDM2Ljc0OCA5Ny4yNzcxIDM2LjgwNDcgOTcuMDM3OCAzNi44NDNDOTYuNzk4NiAzNi44ODA5IDk2LjUzOTQgMzYuOTAwNSA5Ni4yNjAyIDM2LjkwMTNDOTUuNTA3NCAzNi45MDM0IDk0LjkyNzIgMzYuNjk4MiA5NC41MTk3IDM2LjI4NTdDOTQuMTEyMSAzNS44NzMxIDkzLjkwNzIgMzUuMjE3OCA5My45MDQ1IDM0LjMyMDhMOTMuODkyMiAzMC4xOTI2TDkzLjEzOTEgMzAuMTk2NEw5My4xMzQ3IDI4LjY2MzJMOTMuODg3NyAyOC42NTk0TDkzLjg4MTggMjYuNjc3OUw5Ni4wNTggMjYuNjcxNVpNMTA2LjkzNCAyOS45Mzc1TDEwNi4xNzkgMzAuMDUxNkwxMDMuMjI2IDM3LjkzNTFDMTAyLjk5MyAzOC41MTg4IDEwMi42ODIgMzkuMDA4OCAxMDIuMjkyIDM5LjQwMzVDMTAxLjkwMSAzOS43OTg2IDEwMS4zMTIgMzkuOTk3NCAxMDAuNTI1IDQwQzEwMC4zNCA0MC4wMDA1IDEwMC4xNjcgMzkuOTg2IDEwMC4wMDUgMzkuOTU2MkM5OS44NDI1IDM5LjkyNjggOTkuNjUxOCAzOS44ODUgOTkuNDMyMyAzOS44MzFMOTkuNjgxOCAzOC4yMzY5Qzk5Ljc1MTcgMzguMjQ3MiA5OS44MjQgMzguMjU2NSA5OS44OTg4IDM4LjI2NjdDOTkuOTczNiAzOC4yNzYxIDEwMC4wMzggMzguMjgxMiAxMDAuMDkzIDM4LjI4MTJDMTAwLjQ1NyAzOC4yNzk5IDEwMC43MzYgMzguMTkwNSAxMDAuOTMgMzguMDEzQzEwMS4xMjQgMzcuODM1NCAxMDEuMjczIDM3LjYxNCAxMDEuMzc3IDM3LjM1TDEwMS42MjIgMzYuNzM2MUw5OS4wMzcgMzAuMDgwNkw5OC4yODEzIDI5Ljk2MzFMOTguMjc3NSAyOC42NDY2TDEwMi4yNDEgMjguNjM0N0wxMDIuMjQ1IDI5Ljk1MTJMMTAxLjM0IDMwLjEwMzZMMTAyLjQ1NyAzMy4zMzA5TDEwMi41NzEgMzMuOTEzOEwxMDIuNjE2IDMzLjkyMUwxMDMuODgzIDMwLjA5NTlMMTAyLjk3IDI5Ljk0OTFMMTAyLjk2NiAyOC42MzI2TDEwNi45MyAyOC42MjExTDEwNi45MzQgMjkuOTM3NVoiIGZpbGw9IiMxMDBGMEQiLz4KPHBhdGggZD0iTTE0OC43MDkgMTIuMDkyMUwxNDIuMzA1IDE4Ljk5ODFMMTQ1LjA3MyA2LjkxODA5TDE0MS4zODYgOC44Njk3OEwxMzguNjIyIDEuMzUwMTVMMTM1Ljg1NyA4Ljg2OTc4TDEzMi4xNyA2LjkxODA5TDEzNC45MzkgMTguOTk4MUwxMjguMzk4IDExLjk0NDhMMTI3Ljk3NCAxNS4wMjQ3TDEyMi42MTEgMTMuNDYwNkwxMjUuMDg2IDE5LjMxMDNMMTIyLjgxNSAxOS45M0wxMzAuNDc4IDI1LjY1MjhDMTM5LjE5NyAyMi4yODk3IDE0NC42NjcgMjMuMjY2NiAxNDcuODcyIDI0LjU2NkMxNDcuNDAxIDI2LjQwNzYgMTQ2LjcwMyAyOC4xMiAxNDUuNzgxIDI5LjcwMDlDMTQ1LjUyMyAyOS41NTkzIDE0NS4yNTMgMjkuNDIyMyAxNDQuOTY1IDI5LjI5MjFDMTQzLjg1MiAyOC43ODcxIDE0Mi41MTQgMjguMzc3NSAxNDAuOTAzIDI4LjEzODdDMTQwLjI4NCAyOC4wNDY4IDEzOS42MjMgMjcuOTgxNCAxMzguOTIxIDI3Ljk0NDJDMTM4LjcyNSAyNy45MzM4IDEzOC41MjYgMjcuOTI1OCAxMzguMzI0IDI3LjkyQzEzNy45MzkgMjcuOTA5MiAxMzcuNTQxIDI3LjkwNzIgMTM3LjEzMSAyNy45MTQyQzEzNS4zMiAyNy45NDU0IDEzMy4yNjggMjguMTU1NSAxMzAuOTM1IDI4LjYwMjhDMTMwLjg0OCAyOC42MTk4IDEzMC43NjEgMjguNjMzOSAxMzAuNjc1IDI4LjY0OTdDMTMwLjI1IDI4LjcyNjcgMTI5LjgzOCAyOC43OTEyIDEyOS40MzYgMjguODQzOEMxMjMuNTc5IDI5LjYwOTcgMTE5Ljk2NCAyNy44NzU3IDExNy43OTggMjUuODk4QzExNy41NzIgMjUuMjQ5OCAxMTcuMzc4IDI0LjU5MjggMTE3LjIxOSAyMy45MjY5QzExOS4zOTIgMjYuMTk0MiAxMjMuMjIxIDI4LjE4MDcgMTI5LjU2OCAyNS45ODY3TDEyMC45OTQgMTkuNTg0NUwxMjMuOTc2IDE4Ljc3MTNMMTIxLjE5NiAxMi4yMDE4TDEyNy4yOTcgMTMuOTgxNEwxMjcuODI4IDEwLjEzNTFMMTMzLjQ2OSAxNi4yMTc2TDEzMC45ODIgNS4zNjk4MUwxMzUuNDE2IDcuNzE2OTVMMTM4LjExOSAwLjM2NTk1M0MxMzguNDc0IDAuNDEyNjk5IDEzOC44MjggMC40NjQwMDEgMTM5LjE4MiAwLjUxOTE1OUwxNDEuODI4IDcuNzE2OTVMMTQ2LjI2MSA1LjM2OTgxTDE0My43NzYgMTYuMjE3NkwxNDguNzEzIDEwLjg5MjVMMTQ4LjcwOSAxMi4wOTIxWiIgZmlsbD0id2hpdGUiLz4KPHBhdGggZD0iTTEyOS41NDYgMzAuMjA1OEMxMjMuNTA1IDMwLjY4ODYgMTIwLjEwMSAyOS4wMDQxIDExOC4xOCAyNi45MTgxQzExOC40OTIgMjcuNjgzNiAxMTguODQ4IDI4LjQzNjQgMTE5LjI1MiAyOS4xNzU2QzExOS4yNzMgMjkuMjE0NCAxMTkuMjk1IDI5LjI1MiAxMTkuMzE3IDI5LjI5MDdDMTIxLjExNSAzMC42MTEgMTI0LjEzNiAzMS44NjQxIDEyOS4yMTQgMzIuMjc0OUMxMzQuNTQ0IDMyLjcwNjMgMTM4LjA1IDM0LjE0MTUgMTQwLjM1NSAzNS43ODU1QzE0MS43NSAzNC43MDk0IDE0Mi45NzIgMzMuNTI3MiAxNDQuMDIgMzIuMjQxMkMxNDEuNDA5IDMwLjc1MzMgMTM2Ljk5OCAyOS42MTAyIDEyOS41NDYgMzAuMjA1OFoiIGZpbGw9IndoaXRlIi8+CjxwYXRoIGQ9Ik0xMTkuMzE3IDI5LjI5MDZDMTIyLjE5OSAzNC41MDI4IDEyNi44MzEgMzcuNDU1NyAxMzIuMTg0IDM5Ljc4NDVDMTMyLjUwMiAzOS45MjI4IDEzMi44NDggMzkuOTMgMTMzLjE2NSAzOS43ODQ1QzEzNC43MzQgMzkuMDU3IDEzNi40NzggMzguMzMyMyAxMzcuOTQ5IDM3LjQzNkMxMzguODAxIDM2LjkxNjUgMTM5LjYwMyAzNi4zNjYxIDE0MC4zNTUgMzUuNzg1NEMxMzguMDUgMzQuMTQxNCAxMzQuNTQ0IDMyLjcwNjIgMTI5LjIxNCAzMi4yNzQ5QzEyNC4xMzYgMzEuODY0IDEyMS4xMTUgMzAuNjEwOSAxMTkuMzE3IDI5LjI5MDZaTTEzMC45MzUgMjguNjAyOEMxMjQuMTg4IDI5Ljg5NzIgMTIwLjE0NCAyOC4wNDE3IDExNy43OTggMjUuOTAwMUMxMTcuOTE3IDI2LjI0MTggMTE4LjA0MyAyNi41ODE0IDExOC4xOCAyNi45MThDMTIwLjEwMSAyOS4wMDQxIDEyMy41MDUgMzAuNjg4NSAxMjkuNTQ2IDMwLjIwNThDMTM2Ljk5OCAyOS42MTAyIDE0MS40MDkgMzAuNzUzMyAxNDQuMDIgMzIuMjQxMUMxNDQuNjc3IDMxLjQzNDkgMTQ1LjI2NSAzMC41ODc2IDE0NS43ODIgMjkuNjk4OUMxNDIuOTI2IDI4LjEzMDUgMTM4LjMyMSAyNy4xODYxIDEzMC45MzUgMjguNjAyOFoiIGZpbGw9IiMxMDBGMEQiLz4KPHBhdGggZD0iTTE0Ny44NzMgMjQuNTY2NkMxNDguMjggMjIuOTc5NiAxNDguNTE4IDIxLjI5NjcgMTQ4LjU4MSAxOS41MTZDMTQ4LjY2OSAxNy4wNDI4IDE0OC42OTggMTQuNTY3NiAxNDguNzA5IDEyLjA5MkwxNDIuMzA1IDE4Ljk5OEwxNDUuMDczIDYuOTE4MDRMMTQxLjM4NiA4Ljg2OTczTDEzOC42MjIgMS4zNTAxTDEzNS44NTcgOC44Njk3M0wxMzIuMTcgNi45MTgwNEwxMzQuOTM5IDE4Ljk5OEwxMjguMzk4IDExLjk0NDhMMTI3Ljk3NCAxNS4wMjQ3TDEyMi42MTEgMTMuNDYwNkwxMjUuMDg2IDE5LjMxMDNMMTIyLjgxNSAxOS45M0wxMzAuNDc4IDI1LjY1MjhDMTM5LjE5OCAyMi4yODkyIDE0NC42NjkgMjMuMjY2OSAxNDcuODczIDI0LjU2NjZaIiBmaWxsPSIjRTkxRDI3Ii8+CjxwYXRoIGQ9Ik0xNDYuMjYyIDUuMzY5NzdMMTQzLjc3NiAxNi4yMTc2TDE0OC43MTMgMTAuODkyNUMxNDguNzIgOC40NzMgMTQ4LjcxNiA2LjA1MzI4IDE0OC43MzkgMy42MzQ2MkMxNDguNzQ1IDMuMTk0NTIgMTQ4LjY0IDIuOTQ4NDIgMTQ4LjE3NyAyLjc5MDNDMTQ1LjIzMyAxLjc4MDYzIDE0Mi4yMzkgMC45OTYyNjQgMTM5LjE4MiAwLjUxOTEyMUwxNDEuODI4IDcuNzE2OTFMMTQ2LjI2MiA1LjM2OTc3Wk0xMjkuNTY4IDI1Ljk4NjdMMTIwLjk5NCAxOS41ODQ0TDEyMy45NzYgMTguNzcxMkwxMjEuMTk2IDEyLjIwMThMMTI3LjI5NyAxMy45ODEzTDEyNy44MjggMTAuMTM1MUwxMzMuNDY5IDE2LjIxNzZMMTMwLjk4MiA1LjM2OTc3TDEzNS40MTYgNy43MTY5MUwxMzguMTE5IDAuMzY1OTE3QzEzNy4zNzcgMC4yNjgxMDUgMTM2LjYzIDAuMTg3OTQxIDEzNS44ODEgMC4xMjg0NThDMTI5LjUzMSAtMC4zNzQzOTMgMTIzLjM3OSAwLjYyMjQyNyAxMTcuMzgyIDIuNzA3OEMxMTYuODAyIDIuOTEwNzkgMTE2LjYwMyAzLjE2OTQgMTE2LjYxIDMuNzg1NDlDMTE2LjY0NCA2LjUwNjU5IDExNi42NDIgMTEuOTUyNSAxMTYuNjQyIDExLjk1MjVDMTE2LjY0MiAxNC40MDYgMTE2LjYxNyAxNi44NTk1IDExNi42NDcgMTkuMzEzQzExNi42NjggMjAuODk0MiAxMTYuODYyIDIyLjQzMzMgMTE3LjIxOSAyMy45Mjg2QzExOS4zOTIgMjYuMTk2MyAxMjMuMjIxIDI4LjE4MDUgMTI5LjU2OCAyNS45ODY3WiIgZmlsbD0iIzEwMEYwRCIvPgo8L3N2Zz4K",
}
for name, blob in files.items():
    dest = logo_dir / name
    dest.write_bytes(base64.b64decode(blob))
    print("wrote", dest, dest.stat().st_size)
PY
# --- end pm-feedback-10sep-overlays ---
export NPM_CONFIG_PRODUCTION=false
export NODE_ENV=development
npm ci --include=dev
NODE_ENV=production npx next build

# ndx8 FAIL: Vercel Next onBuildComplete only packaged App routes
# (/ , /use-cases, /_not-found). The iframe needs the literal file at
# /instruments/pass-b-chat-v4.1.html on the static root (`out/`).
python3 <<'PY'
import hashlib, shutil
from pathlib import Path

want = "71fd916526ee31c475f9117406d223c041ee309eff8788fa8bcd6f5db94d3e09"
src = Path("public/instruments/pass-b-chat-v4.1.html")
if not src.is_file():
    raise SystemExit(f"missing locked instrument {src}")
html = src.read_bytes()
digest = hashlib.sha256(html).hexdigest()
if digest != want or len(html) != 52699:
    raise SystemExit(f"locked instrument hash/size mismatch {len(html)} {digest}")

out = Path("out/instruments/pass-b-chat-v4.1.html")
out.parent.mkdir(parents=True, exist_ok=True)
out.write_bytes(html)

root = Path("instruments/pass-b-chat-v4.1.html")
root.parent.mkdir(parents=True, exist_ok=True)
root.write_bytes(html)

vercel_static = Path(".vercel/output/static")
if Path("/vercel/output").exists() or True:
    vercel_static.mkdir(parents=True, exist_ok=True)
    # Serve the Next static export as the Vercel static root.
    if Path("out").is_dir():
        for item in Path("out").iterdir():
            dest = vercel_static / item.name
            if dest.exists():
                if dest.is_dir():
                    shutil.rmtree(dest)
                else:
                    dest.unlink()
            if item.is_dir():
                shutil.copytree(item, dest)
            else:
                shutil.copy2(item, dest)
    instrument = vercel_static / "instruments" / "pass-b-chat-v4.1.html"
    instrument.parent.mkdir(parents=True, exist_ok=True)
    instrument.write_bytes(html)
    Path(".vercel/output/config.json").write_text('{"version":3}\n')

for path in (src, out, root, vercel_static / "instruments" / "pass-b-chat-v4.1.html"):
    body = path.read_bytes()
    print("EMIT", path, len(body), hashlib.sha256(body).hexdigest())
    if hashlib.sha256(body).hexdigest() != want:
        raise SystemExit(f"emit mismatch {path}")
print("instrument route ready: /instruments/pass-b-chat-v4.1.html")
PY
ls -la out/instruments/
ls -la instruments/
ls -la .vercel/output/static/instruments/
