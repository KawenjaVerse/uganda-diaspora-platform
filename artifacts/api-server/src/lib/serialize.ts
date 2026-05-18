export function serializeRow<T extends Record<string, unknown>>(row: T): T {
  const result: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(row)) {
    if (value instanceof Date) {
      result[key] = value.toISOString();
    } else {
      result[key] = value;
    }
  }
  return result as T;
}

export function serializeRows<T extends Record<string, unknown>>(rows: T[]): T[] {
  return rows.map(serializeRow);
}
