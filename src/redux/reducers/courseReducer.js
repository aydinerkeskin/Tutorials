import initialState from "./initialState";

export default function courseReducer(state = initialState.courses, action) {
  console.log(
    "courseReducer, state: " +
      JSON.stringify(state) +
      ", action: " +
      JSON.stringify(action)
  );
  switch (action.type) {
    case "CREATE_COURSE":
      return [...state, { ...action.course }];
    default:
      return state;
  }
}
